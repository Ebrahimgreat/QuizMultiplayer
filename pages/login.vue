<script setup="ts">



let credentials=ref({
  email:'',
  password:''
})






async function login()
{
  const supabase=useSupabaseClient()
  try{
    await  supabase.auth.signInWithPassword({
      email:credentials.value.email,
      password:credentials.value.password
    })
    navigateTo('/home');
  }
  catch (error)
  {
    console.log(error)
  }

}
</script>
<template>

 <div class="bg-yellow-400 dark:bg-gray-800 h-screen overflow-hidden flex items-center justify-center">
   <form class="bg-pink shadow-md rounded px-8 pt-6 pb-8 mb-4 w-full">
   <h1 class="text-4xl text-white text-center" >
     Quiz Rabbit
   </h1>
   <div class="mb-4">
     <label class="block text-white text-sm font-bold mb-2">
       Email
     </label>
     <input v-model="credentials.email" class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline" id="username" type="email" placeholder="Username">

     <div class="mb-6">
       <label class="block text-white text-sm font-bold mb-2" for="password">
         Password
       </label>
       <input v-model="credentials.password" class="shadow appearance-none border border-red-500 rounded w-full py-2 px-3 text-gray-700 mb-3 leading-tight focus:outline-none focus:shadow-outline" id="password" type="password" placeholder="******************">
     </div>

     <button @click="login" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline" type="button">
       Sign in
     </button>

     <a class="inline-block align-baseline font-bold text-blue-500 hover:text-blue-800">
       Forgot Password?
     </a>
     <br>
     <NuxtLink to="/register" class="inline-block align-baseline font-bold text-white hover:text-blue-800">
       Dont have an account? Click here to create a new account.
     </NuxtLink>
   </div>
   </form>

 </div>

</template>