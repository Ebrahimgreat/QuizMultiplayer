

import{defineStore} from "pinia";
import{useRoleStore} from "~/stores/role";

export default defineNuxtRouteMiddleware(async (to,from)=>{


    let roleStore=useRoleStore();

    let profileData=ref([])



    const user=useSupabaseUser();

    if(user.value)


   {
       console.log(user.value)
       try{
           const supabase=useSupabaseClient();
           const{data:profile,error:profileError}=await supabase.from('profiles').select('*').eq('user_id',user.value.id).single();

            if(profileError)
            {
                console.log(profile.id);
            }


            await roleStore.setRole(profile?.role);
            await roleStore.setId(profile.id);
            await roleStore.setName(profile.name)

       }
       catch(error)
       {
           console.log("Error");
       }
   }
    if(!user.value && to.path!='/login' && to.path!='/register')
    {
        console.log("path")
        return navigateTo('/login')
    }

});