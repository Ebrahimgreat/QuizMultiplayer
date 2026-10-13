import{useRoleStore} from "~/stores/role";

const PUBLIC_PAGES=['/login','/register'];

export default defineNuxtRouteMiddleware(async (to)=>{
    const roleStore=useRoleStore();
    const user=useSupabaseUser();

    if(!user.value)
    {
        roleStore.clear();
        if(!PUBLIC_PAGES.includes(to.path))
        {
            return navigateTo('/login');
        }
        return;
    }

    // signed-in users don't need the login/register pages
    if(PUBLIC_PAGES.includes(to.path))
    {
        return navigateTo('/home');
    }

    // load the profile once per signed-in user
    if(roleStore.userId!==user.value.id || !roleStore.id)
    {
        const supabase=useSupabaseClient();
        const{data:profile,error}=await supabase.from('profiles').select('*').eq('user_id',user.value.id).maybeSingle();
        if(error)
        {
            console.log(error);
        }
        roleStore.setProfile(profile,user.value.id);
    }

    if(to.path==='/')
    {
        return navigateTo('/home');
    }
});
