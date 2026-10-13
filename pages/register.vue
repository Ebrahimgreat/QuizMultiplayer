<script setup lang="ts">
let credentials=ref({
  email:'',
  password:''
})
let roleSelected=ref('player')
let name=ref('')
const errorMessage=ref('')
const checkEmail=ref(false)
const loading=ref(false)

const roles=[
  {value:'player',title:'Player',text:'Play quizzes, challenge friends, climb the leaderboard.'},
  {value:'content Creater',title:'Quiz creator',text:'Write quizzes for players to take.'}
]

async function register()
{
  const supabase=useSupabaseClient()
  errorMessage.value=''
  loading.value=true
  // profile + stats rows are created by the on_auth_user_created trigger
  const{data,error}=await supabase.auth.signUp({
    email:credentials.value.email,
    password:credentials.value.password,
    options:{
      data:{
        name:name.value.trim(),
        role:roleSelected.value
      }
    }
  })
  loading.value=false
  if(error)
  {
    errorMessage.value=error.message;
    return;
  }
  // no session means Supabase wants the email confirmed first
  if(!data.session)
  {
    checkEmail.value=true;
    return;
  }
  await navigateTo('/home');
}
</script>

<template>
  <AuthCard v-if="checkEmail" title="Check your email">
    <p class="text-cocoa-700 mt-2">
      We sent a confirmation link to <b>{{credentials.email}}</b>. Click it, then come back and log in.
    </p>
    <NuxtLink to="/login" class="btn-primary w-full mt-6">Go to login</NuxtLink>
  </AuthCard>

  <AuthCard v-else title="Create your account" subtitle="It only takes a minute.">
    <form class="space-y-4" @submit.prevent="register">
      <div>
        <label class="label" for="name">Name</label>
        <input id="name" v-model="name" class="input" type="text" autocomplete="nickname" placeholder="What should we call you?" required>
      </div>
      <div>
        <label class="label" for="email">Email</label>
        <input id="email" v-model="credentials.email" class="input" type="email" autocomplete="email" placeholder="you@example.com" required>
      </div>
      <div>
        <label class="label" for="password">Password</label>
        <input id="password" v-model="credentials.password" class="input" type="password" autocomplete="new-password" placeholder="At least 6 characters" minlength="6" required>
      </div>

      <fieldset>
        <legend class="label">I want to…</legend>
        <div class="grid sm:grid-cols-2 gap-3">
          <label
              v-for="role in roles"
              :key="role.value"
              class="cursor-pointer rounded-xl border-2 p-3 transition"
              :class="roleSelected===role.value?'border-amber-400 bg-amber-50':'border-cocoa-100 hover:border-cocoa-200'"
          >
            <input v-model="roleSelected" type="radio" name="role" :value="role.value" class="sr-only">
            <span class="block font-bold">{{role.title}}</span>
            <span class="block text-sm text-cocoa-500">{{role.text}}</span>
          </label>
        </div>
      </fieldset>

      <p v-if="errorMessage" class="rounded-xl bg-red-50 border border-red-200 px-3.5 py-2.5 text-sm text-red-700">{{errorMessage}}</p>

      <button class="btn-primary w-full" type="submit" :disabled="loading">
        {{loading?'Creating account…':'Sign up'}}
      </button>
    </form>

    <template #footer>
      Already have an account?
      <NuxtLink to="/login" class="font-bold text-amber-700 hover:underline">Log in</NuxtLink>
    </template>
  </AuthCard>
</template>
