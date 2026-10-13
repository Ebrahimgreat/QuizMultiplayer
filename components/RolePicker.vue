<script setup lang="ts">
import{useRoleStore} from "~/stores/role";

// Shown to accounts that were created without a role.
const roleStore=useRoleStore();
const supabase=useSupabaseClient();
const user=useSupabaseUser();
const saving=ref(false);
const errorMessage=ref('');

const roles=[
  {value:'player',title:'Player',text:'Play quizzes, challenge friends, climb the leaderboard.'},
  {value:'content Creater',title:'Quiz creator',text:'Write quizzes for players to take.'}
];

async function choose(role)
{
  saving.value=true;
  errorMessage.value='';
  const{data,error}=await supabase.from('profiles').update({role}).eq('user_id',user.value?.id).select('*').maybeSingle();
  saving.value=false;
  if(error || !data)
  {
    console.log(error);
    errorMessage.value='We couldn\'t save your choice. Please try again.';
    return;
  }
  roleStore.setProfile(data,user.value?.id);
  // reload so the page fetches the data for the new role
  reloadNuxtApp();
}
</script>

<template>
  <div class="card p-6 sm:p-8">
    <h2 class="text-2xl font-bold">How do you want to use Quiz Rabbit?</h2>
    <p class="text-cocoa-500 mt-1 mb-5">Your account doesn't have a role yet. Pick one to get started.</p>
    <div class="grid sm:grid-cols-2 gap-3">
      <button
          v-for="role in roles"
          :key="role.value"
          class="rounded-xl border-2 border-cocoa-100 p-4 text-left transition hover:border-amber-400 hover:bg-amber-50"
          :disabled="saving"
          @click="choose(role.value)"
      >
        <span class="block font-bold">{{role.title}}</span>
        <span class="block text-sm text-cocoa-500">{{role.text}}</span>
      </button>
    </div>
    <p v-if="errorMessage" class="text-sm text-red-700 mt-3">{{errorMessage}}</p>
  </div>
</template>
