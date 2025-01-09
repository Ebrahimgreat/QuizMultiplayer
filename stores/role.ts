import{defineStore} from "pinia";
export const useRoleStore=defineStore('role',{
    state:()=>({
        role:'',
        name:'',
        id:''

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
        }
    }
})