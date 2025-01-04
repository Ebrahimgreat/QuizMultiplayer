import{defineStore} from "pinia";
export const useRoleStore=defineStore('role',{
    state:()=>({
        role:'',
        name:''

    }),
    actions:{
        async setRole(role)
        {
            this.role=role;

        }
    }
})