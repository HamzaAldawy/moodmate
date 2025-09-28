import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class MotivationScreen extends StatefulWidget {
  final String result;

  const MotivationScreen({super.key, required this.result});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  late AudioPlayer _audioPlayer;
  bool _isWarming = false;
  bool _warmedUp = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    // Ensure we always start from the beginning when calling play()
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    // One-time warm-up on iOS (and harmless on Android)
    _warmupAudio(); // fire-and-forget
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // ---- First-run warm-up: silently prime AVAudioSession/decoder so the first real play is instant
  Future<void> _warmupAudio() async {
    if (_isWarming || _warmedUp) return;
    _isWarming = true;
    try {
      // Pick a small/default asset that always exists in your bundle
      const warmupAsset = 'audio/Nutr1.m4a'; // change if you prefer another tiny file
      await _audioPlayer.setVolume(0.0);
      // Play briefly to force session/decoder init, then stop & reset
      await _audioPlayer.play(AssetSource(warmupAsset));
      await Future.delayed(const Duration(milliseconds: 300)); // 200–400ms is enough
      await _audioPlayer.stop();
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.setVolume(1.0);
      _warmedUp = true;
      // (Optional) small delay to ensure session settles, avoids clicks on some devices
      // await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      // If warm-up fails, we just proceed; real play will still work (just slower once)
      // ignore
    } finally {
      _isWarming = false;
    }
  }

  // Random text generator
  String getRandomText(String mood) {
    final random = Random();

    List<String> happyTexts = [
      "السعادة التي تشعر بها اليوم هي نتيجة لكل ما مررت به من تحديات وصبر. استمتع بهذه اللحظة بكل تفاصيلها، فالحياة لا تعاش إلا مرة واحدة. لا تجعل القلق من الغد يسرق منك جمال اليوم، فالغد سيأتي بما فيه. ابتسم وشارك فرحتك مع من حولك، فالسعادة تكبر حين تتقاسمه",
      "حين تكون سعيداً، فأنت تمنح قلبك فرصة ليتنفس بحرية من جديد. السعادة ليست مجرد شعور عابر، بل هي طاقة تشحنك بالأمل والإبداع. دع ضوءك الداخلي ينعكس على كل من تلتقي بهم، ليشعروا بدفء ابتسامتك. وما أجمل أن تكون سبباً في إدخال السرور على قلوب الآخرين",
      "السعادة الحقيقية لا تأتي من الأشياء الكبيرة فقط، بل من التفاصيل الصغيرة التي نغفل عنها أحياناً. كوب قهوة في الصباح، كلمة طيبة، لحظة هادئة مع نفسك، كلها مصادر فرح. اجعل قلبك ممتناً لهذه اللحظات البسيطة، فهي التي تضيء أيامك. حينها ستدرك أن السعادة كانت قريبة منك طوال الوقت",
      "عندما تملأ السعادة قلبك، لا تدعها تقف عندك فقط، بل اجعلها جسراً يعبر إلى الآخرين. شارك الضحكة، وازرع الأمل، وكن قدوة بالروح الإيجابية. السعادة مثل النار المضيئة، كلما أشعلت بها قلوباً أكثر، زاد نورها في حياتك. عش بفرح، وستجد أن العالم يبتسم لك بالمقابل",
      "لا تبحث كثيراً عن السعادة في أماكن بعيدة، فهي تسكن في داخلك منذ البداية. كل ما تحتاجه هو أن تفتح قلبك وتسمح لنفسك برؤية الجمال حولك. ابتسم للأشياء الصغيرة، وكن ممتناً لما تملك، وستتفاجأ كيف يصبح يومك مشرقاً. فالسعادة ليست شيئاً ننتظره، بل قرار نعيشه",
      "السعادة هي لغة عالمية يفهمها كل الناس دون حاجة إلى كلمات. ابتسامتك قد تكون أعمق من آلاف العبارات، ونظرتك المتفائلة قد تغير يوماً كاملاً لشخص آخر. لا تقلل أبداً من قيمة لحظات الفرح التي تصنعها. فربما تكون سعادتك اليوم هي الدواء لروح متعبة بجوارك",
      "كلما سمحت لنفسك بالاستمتاع باللحظة، كلما زاد شعورك بالسلام الداخلي. السعادة ليست في امتلاك كل شيء، بل في الرضا بما لديك. خذ نفساً عميقاً، وانظر حولك، ستكتشف أن العالم مليء بالهدايا الصغيرة. الحياة أقصر من أن تقضيها في القلق، فاختر أن تبتسم",
      "السعادة ليست مجرد إحساس وقتي، بل أسلوب حياة تختاره كل يوم. قد تبدأ بابتسامة صغيرة، ثم تتحول إلى طاقة تغير مزاجك بالكامل. لا تنتظر الظروف المثالية كي تفرح، بل اصنع فرحتك وسط أي موقف. فالسعادة قرار داخلي لا تمنحه لك الحياة بل تمنحه أنت لنفسك",
      "أجمل ما في السعادة أنها عدوى تنتقل بسهولة من شخص لآخر. ضحكتك قد ترفع معنويات من حولك دون أن تشعر. اجعل فرحك أسلوباً في التعامل، وسترى كيف ينعكس على كل من يقابلك. وما تمنحه للناس من ابتسامة، سيعود إليك أضعافاً",
      "السعادة الحقيقية لا تعني غياب التحديات، بل تعني امتلاك القلب القادر على الاستمتاع رغم وجودها. تعلم أن ترى الضوء وسط الظلام، وأن تجد أملاً حتى في أصعب الأوقات. هذا ما يجعل فرحتك أصيلة وليست هشة. فالسعيد بحق هو من يعرف كيف يحتفظ بابتسامته مهما كانت الظروف"

    ];

    List<String> sadTexts = [
      "حتى في أصعب اللحظات التي تشعر فيها بالوحدة والضعف، تذكّر أن قوتك الحقيقية لم تُختبر بعد. كل تجربة مؤلمة هي درس جديد يفتح لك باباً لفهم الحياة بصورة أعمق. الألم لا يدوم، لكنه يترك وراءه صلابة في القلب. كن واثقاً أن الغد سيحمل لك نوراً جديداً مهما طال الليل",
      "قد تشعر أحياناً أن الطريق طويل وأن خطواتك لا تترك أثراً، لكن الحقيقة أن كل خطوة تقربك أكثر مما تظن. لا تحكم على نفسك من خلال اللحظة الحالية فقط، فالمستقبل مليء بالفرص التي تنتظرك. امنح نفسك وقتاً للشفاء، ولا تخجل من ضعفك، فحتى الجرح هو علامة على أنك نجوت. ما تمر به اليوم سيكون يوماً ما قصة إلهام لشخص آخر",
      "لا يوجد فشل دائم في الحياة، بل تجارب تعلمنا كيف نقف أقوى في المرة القادمة. كل سقوط هو دعوة للنهوض من جديد بوعي أكبر وعزيمة أشد. الحزن ليس نهاية الطريق، بل محطة مؤقتة تذكرك أنك إنسان حي يمر بمشاعر طبيعية. ثق أنك ستخرج من هذه الفترة بشخصية أكثر نضجاً مما كنت عليه",
      "الحزن يشبه الغيوم السوداء التي تحجب الشمس مؤقتاً، لكنه لا يستطيع أن يمنعها من الظهور مجدداً. الألم مهما كان شديداً، سيذوب مع الوقت كما يذوب الجليد تحت أشعة النهار. لا تجعل هذه اللحظة تعميك عن حقيقة أن حياتك ما زالت تحمل الكثير من الجمال. كل ما تحتاجه هو الصبر والإيمان بأن العاصفة ستمر",
      "عندما تبكي، لا تعتقد أن دموعك ضعف، بل هي طريقة روحك لتتخلص من الثقل الذي تحمله. الدموع تغسل قلبك وتجعلك أكثر استعداداً للبدء من جديد. لا تخف من التعبير عن حزنك، فهذا جزء من الشفاء. وما بعد الشفاء، ستكتشف أن قلبك أصبح أوسع وأكثر رحمة مما كان",
      "الحزن لا يأتي عبثاً، بل يحمل معه رسالة مهمة عن نفسك وعن حياتك. إنه يذكرك بما فقدت، لكنه أيضاً يذكرك بما ما زال لديك. الألم يفتح عينيك على قيم أعمق ويقوي صلتك بذاتك الداخلية. لا تنظر للحزن كعدو، بل كمعلم مؤقت يتركك أقوى مما كنت",
      "قد تشعر أن قلبك مثقل وأن العالم كله ضدك، لكن تذكّر أن هذه مجرد مرحلة مؤقتة. كل ليل مهما طال ينتهي بفجر جديد يبدد الظلام. اصبر ولا تسمح لليأس أن يخدعك، فما تراه اليوم صعباً سيكون غداً مجرد ذكرى. سيأتي وقت تنظر فيه للخلف بفخر لأنك لم تستسلم",
      "الحزن يعطيك فرصة للتفكير العميق وإعادة ترتيب حياتك من جديد. ربما يبدو أنه يكسرك، لكنه في الحقيقة يعيد تشكيلك بطريقة أفضل. الألم يوقظك من غفلة ويذكرك بأهمية الرحمة، سواء تجاه نفسك أو تجاه الآخرين. احتضن هذه المرحلة، فهي بداية نمو داخلي عظيم",
      "حتى وإن شعرت أن الحزن يسلبك طاقتك، فهو لا يستطيع أن يأخذ منك إرادتك. الإرادة هي النار التي تظل مشتعلة في داخلك مهما عصفت بها الرياح. امنح نفسك الراحة، لكن لا تفقد العزيمة أبداً. يوماً ما، ستدرك أن هذه التجربة كانت السبب في نهضتك",
      "الحزن لا يعني النهاية، بل بداية فصل جديد في حياتك. إنك تعيد كتابة قصتك بطريقة أكثر عمقاً وإلهاماً. عندما يزول الألم، ستجد نفسك أقوى وأكثر وعياً من أي وقت مضى. ثق أن هذه اللحظة القاسية ستتحول إلى نقطة انطلاق نحو حياة أجمل"


    ];

    List<String> neutralTexts = [
      "الحياة ليست سباقاً يجب أن تصل فيه أولاً، بل هي رحلة تحتاج أن تستمتع بكل خطوة فيها. عندما يكون مزاجك هادئاً وطبيعياً، فهذه فرصة ذهبية للتفكير بوضوح. استغل هذه اللحظات لتخطط وتعيد ترتيب أولوياتك بعيداً عن ضغوط العاطفة. التوازن في المشاعر هو نعمة لا يقدرها الكثيرون",
      "حين لا تشعر بحزن شديد أو فرح كبير، فهذا لا يعني أن حياتك فارغة، بل على العكس. المزاج الطبيعي يمنحك استقراراً يساعدك على بناء عادات إيجابية. هو الوقت المناسب لتطوير نفسك بهدوء وبلا استعجال. فالحياة ليست دائماً قمماً أو ودياناً، بل أرضاً مستقرة تحتاجها للسير بثبات",
      "المزاج المعتدل يشبه الطقس الربيعي، لا حر شديد ولا برد قاسٍ، بل اعتدال يجعلك مرتاحاً. هذه اللحظات تمنحك فرصة لملاحظة التفاصيل الصغيرة التي قد تتجاهلها في حالات الانفعال. تأمل وجوه الناس من حولك، استمع لأصوات الطبيعة، واستشعر نعمة التنفس بسلام. هذا التوازن هو الأساس لصحة نفسية قوية",
      "حين يكون مزاجك عادياً، اغتنم الفرصة للعمل بتركيز دون تشتت. العاطفة القوية قد تعطل أحياناً الإنتاجية، بينما الاعتدال يمنحك طاقة مستقرة. هذه الحالة النفسية تجعل من السهل عليك الإنجاز بخطوات متوازنة. تذكر أن النجاح لا يبنى في القمم فقط، بل في الأيام العادية أيضاً",
      "المزاج الطبيعي هو مساحة للتأمل والتفكر في نفسك وفي الآخرين. بعيداً عن ضوضاء الحزن أو نشوة الفرح، تجد نفسك أكثر صدقاً مع ذاتك. اسأل نفسك: ما الذي أريد أن أحققه؟ ما الذي يجعلني راضياً عن حياتي؟ هذه الأسئلة تجد لها أجوبة أوضح حين يكون عقلك وقلبك في حالة هدوء",
      "لا تستهِن باللحظات العادية، فهي الأساس الذي تبنى عليه حياتك. إنجاز المهام اليومية البسيطة في حالة مزاج طبيعي قد يحقق لك استقراراً عظيماً على المدى الطويل. لا تحتاج دائماً إلى مشاعر قوية لتتحرك للأمام، أحياناً يكفي أن تستمر بخطوات ثابتة. فالماء الجاري بهدوء هو ما يشق الصخور في النهاية",
      "في المزاج الطبيعي، لديك القدرة على النظر للأمور بموضوعية أكبر. بعيداً عن الانفعال، تستطيع تقييم المواقف واتخاذ قرارات أكثر حكمة. هذه الأوقات هي الأنسب لمواجهة التحديات بعقلانية. تذكر أن الحياد النفسي قوة خفية لا يملكها الكثير",
      "المزاج المعتدل يساعدك على الاستمتاع بالحياة دون اندفاع أو خوف. فهو يتيح لك أن تعيش اللحظة بوعي كامل دون أن تفقد اتزانك. يمكنك أن تضحك ببساطة، وأن تعمل بهدوء، وأن تسترخي بلا قلق. هذه الحالة هي سر العيش بسلام داخلي مستمر",
      "حين لا تكون في قمة الفرح أو قاع الحزن، فأنت في المنطقة الأكثر أماناً للذات. هنا تستطيع أن تبني عادات صحية، وتطور نفسك تدريجياً دون ضغط. هذه الحالة من الاستقرار العاطفي تمنحك فرصة للنمو بصمت وهدوء. فهي بمثابة تربة خصبة تزرع فيها نجاحات المستقبل",
      "الحياة ليست كلها مشاعر قوية، بل هي مزيج من لحظات عادية تشكل معظم أيامنا. الاستمتاع بالهدوء هو مهارة لا تقل أهمية عن عيش الفرح أو مواجهة الحزن. المزاج الطبيعي يمنحك استراحة بين تقلبات العاطفة، وهو ما يحافظ على توازنك الداخلي. فاعتز بهذه اللحظات البسيطة، فهي ما يمنحك القوة للاستمرار"

    ];

    List<String> depressedTexts = [
      "الحزن ليس عيبًا ولا ضعفًا، بل هو إشارة من قلبك بأنك بحاجة إلى عناية وراحة. لا تدع شعورك الحالي يخدعك ويخبرك أنك غير قادر على الاستمرار. الحقيقة أنك نجوت من مئات الأيام الصعبة من قبل، وهذا اليوم لن يكون استثناءً. فقط تذكر أن الظلام مؤقت، والنور في طريقه إليك",
      "الاكتئاب قد يجعلك تشعر وكأنك غريب عن نفسك، لكنه لا يحدد هويتك الحقيقية. أنت أكثر من مشاعرك وأكثر من ألمك. خذ نفسًا عميقًا، واسمح لنفسك أن تؤمن بأن الغد يمكن أن يكون أخف وطأة من اليوم. في كل لحظة يأس، يوجد أمل صغير ينمو بصمت",
      "قد تشعر أن خطواتك ثقيلة وكأنك لا تستطيع التقدم، لكن مجرد محاولتك للنهوض دليل على قوتك. الاكتئاب يحاول أن يخبرك بأنك ضعيف، لكن حقيقة الأمر أنك تقاتل يوميًا معركة لا يراها أحد. وهذا بحد ذاته بطولة عظيمة. لا تقلل أبدًا من شجاعتك",
      "في الأوقات التي يثقل فيها قلبك بالهموم، حاول أن تتذكر أن هذه المشاعر لن تدوم إلى الأبد. الحياة مثل البحر، والمد والجزر لا يتوقفان أبدًا. اليوم قد يكون صعبًا، لكن الغد قد يجلب معه فرصة جديدة وراحة طال انتظارها. استمر، فقصتك لم تنتهِ بعد",
      "عندما يهمس لك صوت داخلي أنك عديم القيمة، قاومه بالحقيقة: أنت مهم، وجودك له أثر، وهناك من يتمنى لك الخير حتى لو لم تره. لا تنسَ أن قيمتك لا تُقاس بإنجازاتك فقط، بل بإنسانيتك وبالرحمة التي تحملها في قلبك. أنت أثمن بكثير مما تعتقد",
      "أحيانًا يبدو الاكتئاب كغيمة سوداء تحجب كل الألوان، لكن الألوان لم تختفِ، بل تنتظر لحظة عودتها. لا تيأس من بطء تقدمك، فكل خطوة مهما كانت صغيرة تُحسب لصالحك. تذكر أن الأشجار لا تنمو بين ليلة وضحاها، لكنها مع الصبر تصبح ظلًا وموطنًا للجمال",
      "الاكتئاب لا يعني أنك مكسور، بل أنك إنسان يمر بمرحلة صعبة. لا تخجل من طلب المساعدة، فاليد الممدودة ليست ضعفًا بل شجاعة. نحن لم نُخلق لنعيش وحدنا، والدعم المتبادل جزء من قوة الإنسان. اسمح لنفسك بأن تكون مُحتضنًا لا مُنهكًا",
      "حتى لو شعرت أن الطريق مظلم بلا نهاية، تذكر أن أصغر شرارة قد تضيء عتمة كاملة. لست بحاجة إلى أن ترى كل الطريق الآن، يكفي أن ترى الخطوة التالية. امنح نفسك فرصة لتستمر بخطوات صغيرة، فالمعجزات غالبًا تبدأ بومضة بسيطة",
      "كل ألم تمر به اليوم سيصبح غدًا جزءًا من قصتك، قصة مليئة بالصمود والتحدي. قد لا ترى المعنى الآن، لكنك يومًا ما ستنظر إلى الوراء وتدرك كم كنت قويًا. تذكر أنك لست ما يفعله الاكتئاب بك، بل ما تختاره أنت رغم وجوده",
      "قد يحاول الاكتئاب أن يقنعك بأنك وحدك في معركتك، لكن الحقيقة أن هناك من يهتم لأمرك ويصلي لأجلك دون أن تدري. لا تنعزل عن العالم، فالتواصل قد يكون جسرًا يخرجك من ظلامك. تذكر أن الإنسانية مبنية على المشاركة، وأن قلبك يستحق أن يُسمع"
      // "كل تحدي يمر بك يقويك أكثر."
    ];


    if (mood == "Happy") {
      return happyTexts[random.nextInt(happyTexts.length)];
    } else if (mood == "Sad") {
      return sadTexts[random.nextInt(sadTexts.length)];
    } else if (mood == "Depressed") {
      return depressedTexts[random.nextInt(depressedTexts.length)];
    } else {
      return neutralTexts[random.nextInt(neutralTexts.length)];
    }
  }

  // Music lists by mood
  List<String> _getMusicList(String mood) {
    if (mood == "Happy") {
      return [
        "audio/Hap1.m4a",
        "audio/Hap2.m4a",
        "audio/Hap3.m4a",
        "audio/Hap4.m4a",
        "audio/Hap5.m4a",
        "audio/Hap6.m4a",
        "audio/Hap7.m4a",
        "audio/Hap8.m4a",
      ];
    } else if (mood == "Sad") {
      return [
        "audio/Sad1.m4a",
        "audio/Sad2.m4a",
        "audio/Sad3.m4a",
        "audio/Sad4.m4a",
        "audio/Sad5.m4a",
        "audio/Sad6.m4a",
        "audio/Sad7.m4a",
        "audio/Sad8.m4a",
      ];
    } else if (mood == "Depressed") {
      return [
        "audio/Encourage1.m4a",
        "audio/Encourage2.m4a",
        "audio/Encourage3.m4a",
        "audio/Encourage4.m4a",
        "audio/Encourage5.m4a",
        "audio/Encourage6.m4a",
        "audio/Encourage7.m4a",
        "audio/Encourage8.m4a",
      ];
    } else {
      return [
        "audio/Nutr1.m4a",
        "audio/Nutr2.m4a",
        "audio/Nutr3.m4a",
        "audio/Nutr4.m4a",
        "audio/Nutr5.m4a",
        "audio/Nutr6.m4a",
        "audio/Nutr7.m4a",
        "audio/Nutr8.m4a",
        "audio/Nutr9.m4a",
      ];
    }
  }

  Future<void> _playMusic(String mood) async {
    // If warm-up still in-flight, wait a tick (prevents a “slow first play”)
    if (_isWarming && !_warmedUp) {
      await Future.delayed(const Duration(milliseconds: 150));
    }

    final musicList = _getMusicList(mood);
    if (musicList.isEmpty) {
      debugPrint("Error: Music list is empty for mood: $mood");
      return;
    }

    final random = Random();
    final randomMusic = musicList[random.nextInt(musicList.length)];
    debugPrint("Playing asset: $randomMusic");

    try {
      // Always start from the beginning, and ensure we’re at audible volume
      await _audioPlayer.stop();
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource(randomMusic));
    } catch (e) {
      debugPrint("Audio Playback Error: $e");
    }
  }

  Future<void> _stopMusic() async {
    await _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    final String mood = widget.result;
    final String message = getRandomText(widget.result);

    return Scaffold(
      appBar: AppBar(title: const Text("نصائح")),
      body: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/app_title.png",
                width: double.infinity,
                height: 75,
                fit: BoxFit.contain,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(135, 249, 249, 248),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 48, 48, 48),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "ممكن نسمع موسيقى",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),

              // Music control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _playMusic(mood);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("تشغيل"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _stopMusic,
                    icon: const Icon(Icons.stop),
                    label: const Text("إيقاف"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
