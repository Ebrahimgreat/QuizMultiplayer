import{defineStore} from "pinia";
export const useRoleStore=defineStore('role',{
    state:()=>({
        role:'',
        name:'',
        id:'',
        userId:''

    }),
    actions:{
        async setRole(role)
        {
            this.role=role;

        },
        async setId(id)
        {
            this.id=id;
        },
        async setName(name){
            this.name=name;
        },
        setProfile(profile,userId)
        {
            this.role=profile?.role ?? '';
            this.name=profile?.name ?? '';
            this.id=profile?.id ?? '';
            this.userId=userId;
        },
        clear()
        {
            this.$reset();
        }
    }
})
