// Minimal Turnip probe: dlopen driver, create instance, enumerate devices.
#include <stdio.h>
#include <dlfcn.h>
#define VK_NO_PROTOTYPES
#include <vulkan/vulkan.h>

int main(int argc, char **argv) {
    const char *path = argc > 1 ? argv[1] : "/data/local/tmp/libvulkan_freedreno.so";
    void *lib = dlopen(path, RTLD_NOW | RTLD_LOCAL);
    if (!lib) { printf("DLFAIL %s\n", dlerror()); return 2; }
    // Android ICDs export only the loader interface, not vk* directly.
    typedef void (*PFN_negotiate)(uint32_t *);
    typedef PFN_vkVoidFunction (*PFN_gipa)(VkInstance, const char *);
    PFN_negotiate pNeg = (PFN_negotiate)dlsym(lib, "vk_icdNegotiateLoaderICDInterfaceVersion");
    PFN_gipa pGIPA = (PFN_gipa)dlsym(lib, "vk_icdGetInstanceProcAddr");
    uint32_t icdVer = 0;
    if (pNeg) { icdVer = 3; pNeg(&icdVer); printf("ICD version=%u\n", icdVer); }
    else printf("NO vk_icdNegotiateLoaderICDInterfaceVersion\n");
    if (!pGIPA) {
        pGIPA = (PFN_gipa)dlsym(lib, "vkGetInstanceProcAddr");
        printf("%s\n", pGIPA ? "using vkGetInstanceProcAddr" : "NO GIPA");
    }
    if (!pGIPA) { printf("SYMFAIL\n"); return 3; }
    PFN_vkCreateInstance pCreate = (PFN_vkCreateInstance)pGIPA(NULL, "vkCreateInstance");
    PFN_vkEnumeratePhysicalDevices pEnum = (PFN_vkEnumeratePhysicalDevices)pGIPA(NULL, "vkEnumeratePhysicalDevices");
    PFN_vkGetPhysicalDeviceProperties pProps = (PFN_vkGetPhysicalDeviceProperties)pGIPA(NULL, "vkGetPhysicalDeviceProperties");
    PFN_vkDestroyInstance pDestroy = (PFN_vkDestroyInstance)pGIPA(NULL, "vkDestroyInstance");
    if (!pCreate || !pEnum || !pProps) { printf("SYMFAIL pCreate=%p pEnum=%p pProps=%p\n", (void*)pCreate, (void*)pEnum, (void*)pProps); return 3; }
    VkApplicationInfo app = { .sType = VK_STRUCTURE_TYPE_APPLICATION_INFO, .apiVersion = VK_API_VERSION_1_1 };
    VkInstanceCreateInfo ci = { .sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO, .pApplicationInfo = &app };
    VkInstance inst = 0;
    VkResult r = pCreate(&ci, 0, &inst);
    if (r != VK_SUCCESS) { printf("CREATEFAIL %d\n", (int)r); return 4; }
    uint32_t n = 0;
    r = pEnum(inst, &n, 0);
    printf("DEVICES %u enum=%d\n", n, (int)r);
    if (n > 0) {
        VkPhysicalDevice pd[8]; uint32_t m = n < 8 ? n : 8;
        pEnum(inst, &m, pd);
        for (uint32_t i = 0; i < m; i++) {
            VkPhysicalDeviceProperties pr;
            pProps(pd[i], &pr);
            printf("DEV %u: %s api=%u.%u.%u driver=0x%x\n", i, pr.deviceName,
                VK_API_VERSION_MAJOR(pr.apiVersion), VK_API_VERSION_MINOR(pr.apiVersion),
                VK_API_VERSION_PATCH(pr.apiVersion), pr.driverVersion);
        }
    }
    pDestroy(inst, 0);
    printf("OK\n");
    return 0;
}
