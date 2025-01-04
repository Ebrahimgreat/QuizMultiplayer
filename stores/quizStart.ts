import{defineStore} from "pinia";
export const usequizStore=defineStore('quiz', {
    state: () => ({
        quizName: '',
        questions: [{question: ''}],
        options: [{A: '', B: '', C: '', D: ''}],
        answers:['']

    }),
    actions: {
        async setData(name, questionData, options,answerData) {
            try {
                this.quizName = name;
                this.questions = questionData?.map((item) => {
                    return {question: item.question};
                });
                this.answers=answerData.map((item)=>{
                    return{answer:item.answer}
                })

                this.options = options.map((item) => {
                    return {A: item.A, B: item.B, C: item.C, D: item.D};
                });
                console.log(this.options.length)


            } catch (error) {
                console.log(error);
            }

        }


    }
})