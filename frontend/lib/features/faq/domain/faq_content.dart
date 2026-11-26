import 'package:flutter/material.dart';

/// One question and its answer, in English and Tagalog.
class FaqItem {
  const FaqItem({
    required this.questionEn,
    required this.answerEn,
    required this.questionTl,
    required this.answerTl,
  });

  final String questionEn;
  final String answerEn;
  final String questionTl;
  final String answerTl;
}

class FaqSection {
  const FaqSection({
    required this.icon,
    required this.titleEn,
    required this.titleTl,
    required this.items,
  });

  final IconData icon;
  final String titleEn;
  final String titleTl;
  final List<FaqItem> items;
}

// To add or fix an answer, edit it here (English AND Tagalog) and rebuild.
// Please have a Tagalog speaker review the Tagalog text, and check the
// Terms definitions against each agency's own page.
const List<FaqSection> faqSections = [
  FaqSection(
    icon: Icons.info_outline_rounded,
    titleEn: "About GABAY",
    titleTl: "Tungkol sa GABAY",
    items: [
      FaqItem(
        questionEn: "What is GABAY?",
        answerEn:
        "GABAY stands for Gabay sa Abot-kayang Benepisyong Alagang Yaman. It helps "
            "you find government health assistance programs, see what you may qualify "
            "for, know which documents to prepare, and find where to apply.",
        questionTl: "Ano ang GABAY?",
        answerTl:
        "Ang GABAY ay nangangahulugang Gabay sa Abot-kayang Benepisyong Alagang "
            "Yaman. Tinutulungan ka nitong maghanap ng mga programa ng gobyerno para sa "
            "tulong pangkalusugan, alamin kung saan ka maaaring kwalipikado, malaman ang "
            "mga dokumentong ihahanda, at makita kung saan mag-a-apply.",
      ),
      FaqItem(
        questionEn: "Does GABAY give the assistance?",
        answerEn:
        "No. GABAY is a guide. It does not approve applications or release any "
            "assistance. You apply at the office or agency that runs each program.",
        questionTl: "Si GABAY ba ang nagbibigay ng tulong?",
        answerTl:
        "Hindi. Gabay lamang ang GABAY. Hindi ito nag-aapruba ng aplikasyon o "
            "nagbibigay ng tulong. Sa tanggapan o ahensyang may hawak ng programa ka "
            "mag-a-apply.",
      ),
      FaqItem(
        questionEn: "Which areas does GABAY cover?",
        answerEn:
        "For now, the programs are for Batangas City residents: city programs, "
            "the 5th Congressional District, the province of Batangas, and national "
            "programs such as PhilHealth, DOH, DSWD and PCSO. More areas can be added "
            "later.",
        questionTl: "Aling mga lugar ang saklaw ng GABAY?",
        answerTl:
        "Sa ngayon, ang mga programa ay para sa mga residente ng Lungsod ng "
            "Batangas: mga programa ng lungsod, ng 5th Congressional District, ng "
            "lalawigan ng Batangas, at mga pambansang programa tulad ng PhilHealth, "
            "DOH, DSWD at PCSO. Maaaring magdagdag ng ibang lugar sa hinaharap.",
      ),
      FaqItem(
        questionEn: "Is the information always up to date?",
        answerEn:
        "Programs, requirements and offices can change. Please confirm with the "
            "office before you go.",
        questionTl: "Laging napapanahon ba ang impormasyon?",
        answerTl:
        "Maaaring magbago ang mga programa, requirement at tanggapan. Mangyaring "
            "makipag-ugnayan muna sa tanggapan bago pumunta.",
      ),
    ],
  ),
  FaqSection(
    icon: Icons.phone_android_rounded,
    titleEn: "Using the app",
    titleTl: "Paggamit ng app",
    items: [
      FaqItem(
        questionEn: "Do I need an account? Why?",
        answerEn:
        "Yes. An account saves your profile so GABAY can match programs to you, "
            "and you can use it again on another phone.",
        questionTl: "Kailangan ko ba ng account? Bakit?",
        answerTl:
        "Oo. Sa account, nase-save ang iyong profile para maitugma ng GABAY ang "
            "mga programa sa iyo, at magagamit mo ito sa ibang telepono.",
      ),
      FaqItem(
        questionEn: "How do I switch to Tagalog?",
        answerEn:
        "Tap EN | TL at the top of the Home or Programs screen. The whole app "
            "switches. Program details stay in English for now.",
        questionTl: "Paano ako lilipat sa Tagalog?",
        answerTl:
        "Pindutin ang EN | TL sa itaas ng Home o Programs. Magbabago ang buong "
            "app. Ingles muna ang detalye ng mga programa sa ngayon.",
      ),
      FaqItem(
        questionEn: "How does \"Match my profile\" work?",
        answerEn:
        "In Programs, open the filter and turn on Match my profile. GABAY uses "
            "the details in your profile to show programs that fit you. The more "
            "complete your profile, the better the match.",
        questionTl: "Paano gumagana ang \"Match my profile\"?",
        answerTl:
        "Sa Programs, buksan ang filter at i-on ang Match my profile. Gagamitin "
            "ng GABAY ang mga detalye sa iyong profile para ipakita ang mga "
            "programang angkop sa iyo. Habang mas kumpleto ang profile, mas tumpak "
            "ang tugma.",
      ),
      FaqItem(
        questionEn: "How do I update my profile?",
        answerEn:
        "Tap the profile button at the top right of Home, change your details, "
            "and press Save.",
        questionTl: "Paano ko ia-update ang aking profile?",
        answerTl:
        "Pindutin ang profile button sa kanang itaas ng Home, baguhin ang mga "
            "detalye, at pindutin ang Save.",
      ),
    ],
  ),
  FaqSection(
    icon: Icons.fact_check_outlined,
    titleEn: "Programs and eligibility",
    titleTl: "Mga programa at kwalipikasyon",
    items: [
      FaqItem(
        questionEn: "What do the program levels mean?",
        answerEn:
        "A level shows who runs the program. City: the Batangas City government. "
            "5th District: the 5th Congressional District office, including programs "
            "it runs with DOH. Provincial: the Batangas provincial government. "
            "National: national agencies such as PhilHealth, DOH, DSWD and PCSO.",
        questionTl: "Ano ang ibig sabihin ng mga antas ng programa?",
        answerTl:
        "Ipinapakita ng antas kung sino ang may hawak ng programa. City: ang "
            "pamahalaan ng Lungsod ng Batangas. 5th District: ang tanggapan ng 5th "
            "Congressional District, kasama ang mga programang kasama nito ang DOH. "
            "Provincial: ang pamahalaang panlalawigan ng Batangas. National: mga "
            "pambansang ahensya tulad ng PhilHealth, DOH, DSWD at PCSO.",
      ),
      FaqItem(
        questionEn: "Does a match mean I will get the assistance?",
        answerEn:
        "No. A match means the program may fit you, based on the details you "
            "gave. The office decides after it checks your documents.",
        questionTl: "Ibig bang sabihin ng tugma ay makakakuha ako ng tulong?",
        answerTl:
        "Hindi. Ang tugma ay nangangahulugang maaaring angkop sa iyo ang "
            "programa, batay sa mga detalyeng ibinigay mo. Ang tanggapan ang "
            "magpapasya matapos suriin ang iyong mga dokumento.",
      ),
      FaqItem(
        questionEn: "What if I do not have PhilHealth?",
        answerEn:
        "Many programs do not need PhilHealth. If you are admitted to a "
            "government hospital in Batangas and have no insurance, there is a "
            "hospital-sponsored PhilHealth enrollment for qualified patients. Search "
            "\"PhilHealth enrollment\" in Programs.",
        questionTl: "Paano kung wala akong PhilHealth?",
        answerTl:
        "Maraming programa ang hindi nangangailangan ng PhilHealth. Kung ikaw ay "
            "naka-confine sa ospital ng gobyerno sa Batangas at walang insurance, may "
            "pagpapa-enroll sa PhilHealth na sinasagot ng ospital para sa mga "
            "kwalipikadong pasyente. Hanapin ang \"PhilHealth enrollment\" sa Programs.",
      ),
      FaqItem(
        questionEn: "Can I apply to more than one program?",
        answerEn:
        "Many people use more than one program, but each office has its own "
            "rules. Ask the office if you are unsure.",
        questionTl: "Maaari ba akong mag-apply sa higit sa isang programa?",
        answerTl:
        "Maraming tao ang gumagamit ng higit sa isang programa, pero may sariling "
            "patakaran ang bawat tanggapan. Magtanong sa tanggapan kung hindi ka "
            "sigurado.",
      ),
    ],
  ),
  FaqSection(
    icon: Icons.assignment_outlined,
    titleEn: "Applying and documents",
    titleTl: "Pag-a-apply at mga dokumento",
    items: [
      FaqItem(
        questionEn: "Where do I apply?",
        answerEn:
        "Each program page shows the implementing office. Apply there, or through "
            "the agency's official channel.",
        questionTl: "Saan ako mag-a-apply?",
        answerTl:
        "Nakalagay sa pahina ng bawat programa ang tanggapang may hawak nito. "
            "Mag-apply doon, o sa opisyal na paraan ng ahensya.",
      ),
      FaqItem(
        questionEn: "Which documents should I prepare?",
        answerEn:
        "Open a program and look at its Requirements checklist. Tick what you "
            "already have. The ticks are only a reminder and are not saved.",
        questionTl: "Anong mga dokumento ang dapat kong ihanda?",
        answerTl:
        "Buksan ang isang programa at tingnan ang Listahan ng mga requirement. "
            "Lagyan ng tsek ang mayroon ka na. Paalala lamang ang mga tsek at hindi "
            "ito nase-save.",
      ),
      FaqItem(
        questionEn: "Can I submit my application in GABAY?",
        answerEn:
        "No. GABAY shows you what you need, then you apply through the program's "
            "official channel.",
        questionTl: "Maaari ba akong magsumite ng aplikasyon sa GABAY?",
        answerTl:
        "Hindi. Ipinapakita ng GABAY ang mga kailangan mo, at pagkatapos ay "
            "mag-a-apply ka sa opisyal na paraan ng programa.",
      ),
    ],
  ),
  FaqSection(
    icon: Icons.lock_outline_rounded,
    titleEn: "Privacy",
    titleTl: "Privacy",
    items: [
      FaqItem(
        questionEn: "Who can see my profile?",
        answerEn:
        "Only you, when you are signed in. Other app users cannot see it.",
        questionTl: "Sino ang makakakita ng aking profile?",
        answerTl:
        "Ikaw lamang, kapag naka-sign in ka. Hindi ito makikita ng ibang "
            "gumagamit ng app.",
      ),
      FaqItem(
        questionEn: "What is my information used for?",
        answerEn:
        "To match programs to you and to show how complete your profile is. GABAY "
            "does not send your details to any agency.",
        questionTl: "Para saan ginagamit ang aking impormasyon?",
        answerTl:
        "Para maitugma ang mga programa sa iyo at ipakita kung gaano na "
            "kakumpleto ang iyong profile. Hindi ipinapadala ng GABAY ang iyong mga "
            "detalye sa anumang ahensya.",
      ),
      FaqItem(
        questionEn: "How do I log out?",
        answerEn: "Open your profile from the top right of Home and tap Log out.",
        questionTl: "Paano ako mag-lo-log out?",
        answerTl:
        "Buksan ang iyong profile sa kanang itaas ng Home at pindutin ang Log out.",
      ),
    ],
  ),
];

/// Plain-language meanings of words used in the programs, grouped by topic.
const List<FaqSection> termSections = [
  FaqSection(
    icon: Icons.help_outline_rounded,
    titleEn: "General",
    titleTl: "Pangkalahatan",
    items: [
      FaqItem(
        questionEn: "Indigent",
        answerEn:
        "Someone whose income is too low to pay for basic needs such as medical "
            "care. Offices often check this with a barangay certificate or a social "
            "worker's assessment.",
        questionTl: "Indigent",
        answerTl:
        "Taong kulang ang kita para sa mga pangunahing pangangailangan tulad ng "
            "pagpapagamot. Madalas itong tinitiyak ng tanggapan sa pamamagitan ng "
            "sertipiko mula sa barangay o ng pagsusuri ng social worker.",
      ),
      FaqItem(
        questionEn: "Social Case Study Report (SCSR)",
        answerEn:
        "A report by a social worker about your situation. Some assistance "
            "programs ask for it.",
        questionTl: "Social Case Study Report (SCSR)",
        answerTl:
        "Ulat ng social worker tungkol sa iyong sitwasyon. Hinihingi ito ng ilang "
            "programa ng tulong.",
      ),
    ],
  ),
  FaqSection(
    icon: Icons.local_hospital_outlined,
    titleEn: "Hospital bills",
    titleTl: "Bayarin sa ospital",
    items: [
      FaqItem(
        questionEn: "Guarantee Letter (GL)",
        answerEn:
        "A letter from a government office that promises to pay part or all of "
            "your hospital bill, up to a set amount. You give it to the hospital's "
            "billing section.",
        questionTl: "Guarantee Letter (GL)",
        answerTl:
        "Liham mula sa tanggapan ng gobyerno na nangangakong babayaran ang bahagi "
            "o buong bayarin mo sa ospital, hanggang sa takdang halaga. Ibibigay mo "
            "ito sa billing section ng ospital.",
      ),
      FaqItem(
        questionEn: "Malasakit Center",
        answerEn:
        "A one-stop office inside some government hospitals where the DOH, DSWD, "
            "PCSO and PhilHealth help desks are in one place.",
        questionTl: "Malasakit Center",
        answerTl:
        "Isang one-stop na opisina sa loob ng ilang ospital ng gobyerno kung saan "
            "magkakasama ang help desk ng DOH, DSWD, PCSO at PhilHealth.",
      ),
    ],
  ),
  FaqSection(
    icon: Icons.health_and_safety_outlined,
    titleEn: "PhilHealth",
    titleTl: "PhilHealth",
    items: [
      FaqItem(
        questionEn: "No Balance Billing (NBB)",
        answerEn:
        "A PhilHealth rule under which qualified patients should pay nothing "
            "extra for covered services. Ask the hospital's PhilHealth desk if you "
            "qualify.",
        questionTl: "No Balance Billing (NBB)",
        answerTl:
        "Patakaran ng PhilHealth na hindi na dapat magbayad ng dagdag ang mga "
            "kwalipikadong pasyente para sa mga sakop na serbisyo. Magtanong sa "
            "PhilHealth desk ng ospital kung kwalipikado ka.",
      ),
      FaqItem(
        questionEn: "Z Benefits",
        answerEn:
        "PhilHealth packages for costly, long-term illnesses (catastrophic "
            "illness), such as certain cancers and kidney conditions, with set "
            "coverage for treatment.",
        questionTl: "Z Benefits",
        answerTl:
        "Mga package ng PhilHealth para sa magastos at pangmatagalang sakit "
            "(catastrophic illness), tulad ng ilang uri ng kanser at sakit sa bato, "
            "na may takdang sakop para sa gamutan.",
      ),
      FaqItem(
        questionEn: "YAKAP",
        answerEn:
        "PhilHealth's Yaman ng Kalusugan Program, a primary care package for "
            "check-ups and basic health services at accredited clinics.",
        questionTl: "YAKAP",
        answerTl:
        "Ang Yaman ng Kalusugan Program ng PhilHealth, isang primary care package "
            "para sa konsultasyon at mga pangunahing serbisyong pangkalusugan sa mga "
            "akreditadong klinika.",
      ),
    ],
  ),
  FaqSection(
    icon: Icons.volunteer_activism_outlined,
    titleEn: "Assistance programs",
    titleTl: "Mga programa ng tulong",
    items: [
      FaqItem(
        questionEn: "MAIFIP",
        answerEn:
        "The DOH's Medical Assistance for Indigent and Financially-Incapacitated "
            "Patients program. It helps pay for hospital bills, medicines and other "
            "treatment costs.",
        questionTl: "MAIFIP",
        answerTl:
        "Programa ng DOH na Medical Assistance for Indigent and "
            "Financially-Incapacitated Patients. Tumutulong ito sa bayarin sa ospital, "
            "gamot at iba pang gastos sa pagpapagamot.",
      ),
      FaqItem(
        questionEn: "AICS",
        answerEn:
        "The DSWD's Assistance to Individuals in Crisis Situations. It includes "
            "medical aid for people in a crisis.",
        questionTl: "AICS",
        answerTl:
        "Ang Assistance to Individuals in Crisis Situations ng DSWD. Kasama rito "
            "ang tulong medikal para sa mga taong nasa krisis.",
      ),
    ],
  ),
];