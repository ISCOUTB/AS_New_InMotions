function likertOptions(questionId) {
  return [
    { id: `${questionId}_1`, text: 'No me identifico', score: 1, interpretation: 'Esto no me ha ocurrido en el periodo evaluado.' },
    { id: `${questionId}_2`, text: 'Poco', score: 2, interpretation: 'Me ha ocurrido muy esporádicamente.' },
    { id: `${questionId}_3`, text: 'Moderadamente', score: 3, interpretation: 'Me ha ocurrido con cierta frecuencia.' },
    { id: `${questionId}_4`, text: 'Bastante', score: 4, interpretation: 'Me ha ocurrido frecuentemente.' },
    { id: `${questionId}_5`, text: 'Totalmente', score: 5, interpretation: 'Esta afirmación me describe completamente.' },
  ];
}

function q({ id, order, area, question, type = 'Estándar', isCritical = false }) {
  return { id, order, area, question, type, isCritical, isActive: true, options: likertOptions(id) };
}

const TRIAGE_QUESTIONS = [
  q({ id: 'A1', order: 1, area: 'Depresión', question: 'He sentido poco interés o placer en hacer cosas que antes disfrutaba.' }),
  q({ id: 'A2', order: 2, area: 'Depresión', question: 'Me he sentido triste, vacío/a o sin esperanza la mayor parte del tiempo.' }),
  q({ id: 'A3', order: 3, area: 'Depresión', question: 'He tenido dificultad para dormir (insomnio) o he dormido demasiado.' }),
  q({ id: 'A4', order: 4, area: 'Depresión', question: 'Me he sentido cansado/a o con poca energía, incluso después de descansar.' }),
  q({ id: 'A5', order: 5, area: 'Crisis', question: 'He pensado que sería mejor no estar aquí o me he hecho daño de alguna forma.', type: 'Crítico', isCritical: true }),
  q({ id: 'B1', order: 6, area: 'Ansiedad', question: 'Me he sentido nervioso/a, ansioso/a o con los nervios de punta.' }),
  q({ id: 'B2', order: 7, area: 'Ansiedad', question: 'No he podido dejar de preocuparme o controlar mis pensamientos ansiosos.' }),
  q({ id: 'B3', order: 8, area: 'Ansiedad', question: 'Me he preocupado demasiado por diferentes situaciones de mi vida.' }),
  q({ id: 'B4', order: 9, area: 'Ansiedad', question: 'He tenido dificultad para relajarme o me siento inquieto/a físicamente.' }),
  q({ id: 'B5', order: 10, area: 'Ansiedad', question: 'Me he irritado o molestado con facilidad por cosas pequeñas.' }),
  q({ id: 'C1', order: 11, area: 'Estrés', question: 'Me he sentido abrumado/a por mis responsabilidades diarias.' }),
  q({ id: 'C2', order: 12, area: 'Estrés', question: 'He tenido dificultad para concentrarme en tareas cotidianas.' }),
  q({ id: 'C3', order: 13, area: 'Estrés', question: 'Siento que no tengo tiempo para descansar o recuperarme.' }),
  q({ id: 'C4', order: 14, area: 'Estrés', question: 'He experimentado tensión muscular, dolores de cabeza o malestar físico sin causa médica clara.' }),
  q({ id: 'D1', order: 15, area: 'Regulación', question: 'Me cuesta manejar emociones intensas como tristeza, enojo o miedo.' }),
  q({ id: 'D2', order: 16, area: 'Regulación', question: 'Cuando algo sale mal, tiendo a pensar que todo está perdido.' }),
  q({ id: 'D3', order: 17, area: 'Regulación', question: 'Siento que no tengo herramientas para afrontar momentos difíciles.' }),
  q({ id: 'D4', order: 18, area: 'Regulación', question: 'Evito enfrentar problemas porque me generan mucha ansiedad o malestar.' }),
  q({ id: 'E1', order: 19, area: 'Social', question: 'Me he aislado de familiares o amigos, evitando contacto social.' }),
  q({ id: 'E2', order: 20, area: 'Social', question: 'He sentido que no puedo cumplir con mis responsabilidades (estudio, trabajo, hogar).' }),
  q({ id: 'E3', order: 21, area: 'Social', question: 'He notado que mi estado emocional afecta mis relaciones con otras personas.' }),
  q({ id: 'F1', order: 22, area: 'Crisis', question: 'He pensado que sería mejor no estar aquí o me he hecho daño de alguna forma.', type: 'Crítico', isCritical: true }),
  q({ id: 'F2', order: 23, area: 'Crisis', question: 'He tenido pensamientos sobre lastimarme o terminar con mi vida.', type: 'Crítico', isCritical: true }),
];

module.exports = { TRIAGE_QUESTIONS };
