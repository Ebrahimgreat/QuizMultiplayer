<script setup lang="ts">
let credentials=ref({
  email:'',
  password:''
})
const errorMessage=ref('')
const loading=ref(false)

async function login()
{
  const supabase=useSupabaseClient()
  errorMessage.value=''
  loading.value=true
  const{error}=await supabase.auth.signInWithPassword({
    email:credentials.value.email,
    password:credentials.value.password
  })
  loading.value=false
  if(error)
  {
    errorMessage.value=error.message==='Email not confirmed'
      ?'Please confirm your email first. Check your inbox for the link.'
      :error.message
    return;
  }
  await navigateTo('/home');
}
</script>

<template>
  <AuthCard title="Welcome back" subtitle="Log in to keep playing.">
    <form class="space-y-4" @submit.prevent="login">
      <div>
        <label class="label" for="email">Email</label>
        <input id="email" v-model="credentials.email" class="input" type="email" autocomplete="email" placeholder="you@example.com" required>
      </div>
      <div>
        <label class="label" for="password">Password</label>
        <input id="password" v-model="credentials.password" class="input" type="password" autocomplete="current-password" placeholder="Your password" required>
      </div>

      <p v-if="errorMessage" class="rounded-xl bg-red-50 border border-red-200 px-3.5 py-2.5 text-sm text-red-700">{{errorMessage}}</p>

      <button class="btn-primary w-full" type="submit" :disabled="loading">
        {{loading?'Logging in…':'Log in'}}
      </button>
    </form>

    <template #footer>
      New here?
      <NuxtLink to="/register" class="font-bold text-amber-700 hover:underline">Create an account</NuxtLink>
    </template>
  </AuthCard>
</template>
