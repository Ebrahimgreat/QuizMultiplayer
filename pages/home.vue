<script setup lang="ts">
import{useRoleStore} from "~/stores/role";
import{categoryName} from "~/composables/useQuiz";

const roleStore=useRoleStore();
const role=computed(()=>roleStore.role);
const name=computed(()=>roleStore.name);
const profile=computed(()=>roleStore.id);

const loading=ref(true);
const stats=ref({points:0,games_played:0});
const rank=ref<number|null>(null);
const challenges=ref([]);
const quizInformation=ref([]);
const challengesOnMyQuizzes=ref(0);

async function getPlayerData()
{
  const supabase=useSupabaseClient();

  const{data:statsValues}=await supabase.from('stats').select('*').eq('user_profile_id',profile.value).maybeSingle();
  if(statsValues)
  {
    stats.value=statsValues;
    const{count}=await supabase.from('stats').select('id',{count:'exact',head:true}).gt('points',statsValues.points);
    rank.value=(count??0)+1;
  }

  const{data:challengeValues,error}=await supabase
      .from('challenge')
      .select('*, quiz(name), challenger:profiles!challenge_challenger_id_fkey(name), reciever:profiles!challenge_reciever_id_fkey(name)')
      .or(`challenger_id.eq.${profile.value},reciever_id.eq.${profile.value}`)
      .order('created_at',{ascending:false});
  if(error)
  {
    console.log(error);
  }

  challenges.value=(challengeValues??[]).map((c)=>{
    const iAmChallenger=c.challenger_id==profile.value;
    const myScore=iAmChallenger?c.challenger_score:c.reciever_score;
    const theirScore=iAmChallenger?c.reciever_score:c.challenger_score;
    let result;
    if(c.status==='completed')
    {
      result=c.winner==null?'Draw':c.winner==profile.value?'Won':'Lost';
    }
    else if(c.status==='live')
    {
      result='Unfinished';
    }
    else if(myScore==null)
    {
      result='Your turn';
    }
    else
    {
      result='Waiting';
    }
    return{
      id:c.id,
      quizId:c.quiz_id,
      quizName:c.quiz?.name??'Live game',
      opponent:(iAmChallenger?c.reciever?.name:c.challenger?.name)??'Unknown',
      myScore,
      theirScore,
      result
    };
  });
}

async function getCreatorData()
{
  const supabase=useSupabaseClient();
  const user=useSupabaseUser();
  const{data:quizData}=await supabase
      .from('quiz')
      .select('*, quiz_question(count)')
      .eq('users_id',user.value?.id)
      .order('created_at',{ascending:false});
  quizInformation.value=quizData??[];

  const ids=quizInformation.value.map((q)=>q.id);
  if(ids.length)
  {
    const{count}=await supabase.from('challenge').select('id',{count:'exact',head:true}).in('quiz_id',ids);
    challengesOnMyQuizzes.value=count??0;
  }
}

async function toggleQuiz(item)
{
  const supabase=useSupabaseClient();
  const status=item.status==='deactivated'?'active':'deactivated';
  const{error}=await supabase.from('quiz').update({status}).eq('id',item.id);
  if(error)
  {
    console.log(error);
    return;
  }
  item.status=status;
}

const resultStyle={
  'Won':'bg-emerald-100 text-emerald-800',
  'Lost':'bg-red-100 text-red-700',
  'Draw':'bg-cocoa-100 text-cocoa-700',
  'Waiting':'bg-sky-100 text-sky-800',
  'Your turn':'bg-amber-100 text-amber-800',
  'Unfinished':'bg-cocoa-100 text-cocoa-500'
};

const activeCount=computed(()=>quizInformation.value.filter((q)=>q.status!=='deactivated').length);

onMounted(async ()=>{
  try{
    if(role.value==='player')
    {
      await getPlayerData();
    }
    else if(role.value==='content Creater')
    {
      await getCreatorData();
    }
  }
  catch(error)
  {
    console.log(error);
  }
  loading.value=false;
});
</script>

<template>
  <div class="page">
    <div class="flex flex-wrap items-end justify-between gap-4 mb-8">
      <div>
        <p class="text-cocoa-500 font-bold">Welcome back</p>
        <h1 class="page-title">{{name||'Friend'}}</h1>
      </div>
      <NuxtLink v-if="role==='player'" to="/quiz" class="btn-primary">Play a quiz</NuxtLink>
      <NuxtLink v-else-if="role==='content Creater'" to="/quiz" class="btn-primary">Create a quiz</NuxtLink>
    </div>

    <RolePicker v-if="!role" />

    <!-- Player -->
    <template v-if="role==='player'">
      <div class="grid grid-cols-3 gap-3 sm:gap-4 mb-10">
        <div class="card p-4 sm:p-5">
          <p class="text-xs sm:text-sm font-bold text-cocoa-500 uppercase tracking-wide">Points</p>
          <p class="font-display text-3xl sm:text-4xl font-bold mt-1">{{stats.points}}</p>
        </div>
        <div class="card p-4 sm:p-5">
          <p class="text-xs sm:text-sm font-bold text-cocoa-500 uppercase tracking-wide">Rank</p>
          <p class="font-display text-3xl sm:text-4xl font-bold mt-1">{{rank?`#${rank}`:'–'}}</p>
        </div>
        <div class="card p-4 sm:p-5">
          <p class="text-xs sm:text-sm font-bold text-cocoa-500 uppercase tracking-wide">Games</p>
          <p class="font-display text-3xl sm:text-4xl font-bold mt-1">{{stats.games_played}}</p>
        </div>
      </div>

      <h2 class="text-2xl font-bold mb-4">Challenges</h2>
      <div v-if="loading" class="card p-6 text-cocoa-500">Loading…</div>
      <div v-else-if="challenges.length===0" class="card p-8 text-center">
        <p class="font-bold">No challenges yet</p>
        <p class="text-cocoa-500 mt-1">Pick a quiz and challenge another player to see it here.</p>
      </div>
      <div v-else class="table-wrap">
        <table>
          <thead>
          <tr>
            <th>Quiz</th>
            <th>Opponent</th>
            <th>You</th>
            <th>Them</th>
            <th>Result</th>
          </tr>
          </thead>
          <tbody>
          <tr v-for="item in challenges" :key="item.id">
            <td class="font-bold">{{item.quizName}}</td>
            <td>{{item.opponent}}</td>
            <td>{{item.myScore??'–'}}</td>
            <td>{{item.theirScore??'–'}}</td>
            <td>
              <NuxtLink
                  v-if="item.result==='Your turn' && item.quizId"
                  :to="{path:'/quizScreen',query:{id:item.quizId,challenge:item.id}}"
                  class="btn-primary !py-1.5 !px-3 text-sm"
              >
                Play now
              </NuxtLink>
              <span v-else class="pill" :class="resultStyle[item.result]">{{item.result}}</span>
            </td>
          </tr>
          </tbody>
        </table>
      </div>
    </template>

    <!-- Content creator -->
    <template v-if="role==='content Creater'">
      <div class="grid grid-cols-3 gap-3 sm:gap-4 mb-10">
        <div class="card p-4 sm:p-5">
          <p class="text-xs sm:text-sm font-bold text-cocoa-500 uppercase tracking-wide">Quizzes</p>
          <p class="font-display text-3xl sm:text-4xl font-bold mt-1">{{quizInformation.length}}</p>
        </div>
        <div class="card p-4 sm:p-5">
          <p class="text-xs sm:text-sm font-bold text-cocoa-500 uppercase tracking-wide">Active</p>
          <p class="font-display text-3xl sm:text-4xl font-bold mt-1">{{activeCount}}</p>
        </div>
        <div class="card p-4 sm:p-5">
          <p class="text-xs sm:text-sm font-bold text-cocoa-500 uppercase tracking-wide">Challenges</p>
          <p class="font-display text-3xl sm:text-4xl font-bold mt-1">{{challengesOnMyQuizzes}}</p>
        </div>
      </div>

      <h2 class="text-2xl font-bold mb-4">Your quizzes</h2>
      <div v-if="loading" class="card p-6 text-cocoa-500">Loading…</div>
      <div v-else-if="quizInformation.length===0" class="card p-8 text-center">
        <p class="font-bold">You haven't made a quiz yet</p>
        <p class="text-cocoa-500 mt-1 mb-4">Players can only play quizzes that creators like you write.</p>
        <NuxtLink to="/quiz" class="btn-primary">Create your first quiz</NuxtLink>
      </div>
      <div v-else class="table-wrap">
        <table>
          <thead>
          <tr>
            <th>Quiz</th>
            <th>Category</th>
            <th>Questions</th>
            <th>Status</th>
            <th></th>
          </tr>
          </thead>
          <tbody>
          <tr v-for="item in quizInformation" :key="item.id">
            <td class="font-bold">{{item.name}}</td>
            <td>{{categoryName(item.quiz_category)}}</td>
            <td>{{item.quiz_question?.[0]?.count??0}}</td>
            <td>
              <span class="pill" :class="item.status==='deactivated'?'bg-cocoa-100 text-cocoa-500':'bg-emerald-100 text-emerald-800'">
                {{item.status==='deactivated'?'Hidden':'Live'}}
              </span>
            </td>
            <td class="text-right">
              <button
                  :class="item.status==='deactivated'?'btn-secondary':'btn-danger'"
                  class="!py-1.5 !px-3 text-sm"
                  @click="toggleQuiz(item)"
              >
                {{item.status==='deactivated'?'Make live':'Hide'}}
              </button>
            </td>
          </tr>
          </tbody>
        </table>
      </div>
    </template>
  </div>
</template>
