-- =============================================================================
-- FCIT SRS — Data Patch
-- Generated: 2026-05-27
-- Source:    bylaw-2024-7-73-14-33.pdf  +  info.pdf
-- Database:  student_registration_system (PostgreSQL 16)
-- =============================================================================
-- HOW TO APPLY:
--   psql -U postgres -d student_registration_system -f fcit_db_patch.sql
-- Or inside Docker:
--   docker compose exec postgres psql -U postgres -d student_registration_system -f /fcit_db_patch.sql
-- =============================================================================

BEGIN;

-- ============================================================
-- SECTION 1 — COURSE CATALOG (curriculum_plans)
-- Full seed from bylaw-2024-7-73-14-33.pdf
-- ============================================================
-- Assumed schema (adjust column names if yours differ):
--   curriculum_plans(
--     code          VARCHAR PRIMARY KEY,
--     name_ar       TEXT,
--     name_en       TEXT,
--     credits       INT,
--     lecture_hours INT,
--     lab_hours     INT,
--     department    VARCHAR,   -- 'UNIV','COLLEGE_MATH','COLLEGE_CS','CS','IS','IT','SE'
--     course_type   VARCHAR,   -- 'mandatory','elective'
--     year_level    INT,
--     created_at    TIMESTAMPTZ DEFAULT NOW()
--   )
-- ============================================================

-- ---- University Requirements — Mandatory --------------------
INSERT INTO curriculum_plans (code, name_ar, name_en, credits, lecture_hours, lab_hours, department, course_type)
VALUES
  ('UNV111','كتابة التقارير الفنية',   'Technical Report Writing',  2, 2, 0, 'UNIV', 'mandatory'),
  ('UNV112','قضايا مجتمعية',           'Societal Issues',           2, 2, 0, 'UNIV', 'mandatory'),
  ('UNV113','لغة إنجليزية (1)',        'English Language (1)',      2, 2, 0, 'UNIV', 'mandatory'),
  ('UNV114','مهارات الإتصال',          'Communication Skills',      2, 2, 0, 'UNIV', 'mandatory')
ON CONFLICT (code) DO UPDATE SET
  name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
  credits = EXCLUDED.credits, lecture_hours = EXCLUDED.lecture_hours,
  lab_hours = EXCLUDED.lab_hours;

-- ---- University Requirements — Elective (pick 6 credits) ----
INSERT INTO curriculum_plans (code, name_ar, name_en, credits, lecture_hours, lab_hours, department, course_type)
VALUES
  ('UNV115','مبادئ علم النفس',               'Fundamentals of Psychology',  2, 2, 0, 'UNIV', 'elective'),
  ('UNV116','مبادئ علم الاجتماع',            'Fundamentals of Sociology',   2, 2, 0, 'UNIV', 'elective'),
  ('UNV117','سياسات مقارنة',                 'Comparative Politics',        2, 2, 0, 'UNIV', 'elective'),
  ('UNV118','موضوعات مختارة في الإنسانيات', 'Selected Topics in Humanities',2, 2, 0,'UNIV', 'elective'),
  ('UNV119','الأخلاق والمهنية',              'Ethics and Professionalism',  2, 2, 0, 'UNIV', 'elective'),
  ('UNV120','تسويق ومبيعات',                 'Marketing and Sales',         2, 2, 0, 'UNIV', 'elective'),
  ('UNV121','لغة إنجليزية (2)',              'English Language (2)',        2, 2, 0, 'UNIV', 'elective'),
  ('UNV411','ريادة الأعمال',                 'Entrepreneurship',            2, 2, 0, 'UNIV', 'elective')
ON CONFLICT (code) DO UPDATE SET
  name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
  credits = EXCLUDED.credits, lecture_hours = EXCLUDED.lecture_hours,
  lab_hours = EXCLUDED.lab_hours;

-- ---- College Requirements — Math & Basic Sciences (21h) -----
INSERT INTO curriculum_plans (code, name_ar, name_en, credits, lecture_hours, lab_hours, department, course_type)
VALUES
  ('BS111','رياضيات (1)',           'Math (1)',                       3, 2, 2, 'COLLEGE_MATH', 'mandatory'),
  ('BS112','رياضيات متقطعة',        'Discrete Mathematics',          3, 2, 2, 'COLLEGE_MATH', 'mandatory'),
  ('BS113','رياضيات (2)',           'Math (2)',                       3, 2, 2, 'COLLEGE_MATH', 'mandatory'),
  ('BS114','رياضيات (3)',           'Math (3)',                       3, 2, 2, 'COLLEGE_MATH', 'mandatory'),
  ('BS115','إلكترونيات',            'Electronics',                   3, 2, 2, 'COLLEGE_MATH', 'mandatory'),
  ('BS116','إحصاء واحتمالات (1)',   'Probability and Statistics (1)',3, 2, 2, 'COLLEGE_MATH', 'mandatory'),
  ('BS117','بحوث العمليات',         'Operations Research',           3, 2, 2, 'COLLEGE_MATH', 'mandatory')
ON CONFLICT (code) DO UPDATE SET
  name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
  credits = EXCLUDED.credits, lecture_hours = EXCLUDED.lecture_hours,
  lab_hours = EXCLUDED.lab_hours;

-- ---- College Requirements — Basic CS (39h) ------------------
INSERT INTO curriculum_plans (code, name_ar, name_en, credits, lecture_hours, lab_hours, department, course_type)
VALUES
  ('CS111','أساسيات علوم الحاسب',          'Fundamentals of Computer Science',      3, 2, 2, 'COLLEGE_CS', 'mandatory'),
  ('CS112','برمجة هيكلية',                 'Structured Programming',                3, 2, 2, 'COLLEGE_CS', 'mandatory'),
  ('IT111','أساسيات تكنولوجيا المعلومات', 'Fundamentals of Information Technology',3, 2, 2, 'COLLEGE_CS', 'mandatory'),
  ('IS111','مقدمة في نظم المعلومات',       'Introduction to Information Systems',   2, 1, 1, 'COLLEGE_CS', 'mandatory'),
  ('CS211','برمجة شيئية',                  'Object Oriented Programming',           3, 2, 2, 'COLLEGE_CS', 'mandatory'),
  ('CS212','هياكل البيانات',               'Data Structures',                       3, 2, 2, 'COLLEGE_CS', 'mandatory'),
  ('SE211','مقدمة في هندسة البرمجيات',    'Introduction to Software Engineering',  3, 2, 2, 'COLLEGE_CS', 'mandatory'),
  ('IS211','مقدمة في نظم قواعد البيانات', 'Introduction to Database Systems',      3, 2, 2, 'COLLEGE_CS', 'mandatory'),
  ('IS212','طرق الأمثلية',                 'Optimization Methods',                  3, 2, 2, 'COLLEGE_CS', 'mandatory'),
  ('IT211','تصميم المنطق الرقمي',          'Digital Logic Design',                  3, 2, 2, 'COLLEGE_CS', 'mandatory'),
  ('IT212','تكنولوجيا شبكات الحاسب',       'Computer Network Technology',           3, 2, 2, 'COLLEGE_CS', 'mandatory'),
  ('CS213','تحليل وتصميم الخوارزميات',    'Algorithm Analysis and Design',         3, 2, 2, 'COLLEGE_CS', 'mandatory'),
  ('CS214','نظم التشغيل',                  'Operating Systems',                     3, 2, 2, 'COLLEGE_CS', 'mandatory')
ON CONFLICT (code) DO UPDATE SET
  name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
  credits = EXCLUDED.credits, lecture_hours = EXCLUDED.lecture_hours,
  lab_hours = EXCLUDED.lab_hours;

-- ---- CS Program — Mandatory Applied (48h) -------------------
INSERT INTO curriculum_plans (code, name_ar, name_en, credits, lecture_hours, lab_hours, department, course_type)
VALUES
  ('IS311', 'تحليل وتصميم نظم المعلومات',     'Analysis and Design of Information Systems',  3,2,2,'CS','mandatory'),
  ('CS311', 'أمن الحاسب',                      'Computer Security',                           3,2,2,'CS','mandatory'),
  ('CS312', 'تنظيم وبنية الحاسبات',            'Computer Organization and Architecture',       3,2,2,'CS','mandatory'),
  ('CS313', 'الذكاء الاصطناعي',                'Artificial Intelligence',                     3,2,2,'CS','mandatory'),
  ('IT311', 'الرسم بالحاسب',                   'Computer Graphic',                            3,2,2,'CS','mandatory'),
  ('CS314', 'تعلم الآلة',                      'Machine Learning',                            3,2,2,'CS','mandatory'),
  ('CS315', 'تحليل البيانات الكبيرة',          'Big Data Analysis',                           3,2,2,'CS','mandatory'),
  ('CS316', 'نظم التشغيل المتقدمة',            'Advanced Operating Systems',                  3,2,2,'CS','mandatory'),
  ('SE315', 'هندسة البرمجيات المتقدمة',        'Advanced Software Engineering',               3,2,2,'CS','mandatory'),
  ('IS318', 'نظرية المعلومات وضغط البيانات',   'Information Theory and Data Compression',    3,2,2,'CS','mandatory'),
  ('CS411', 'نظرية الحاسبات',                  'Computation Theory',                          3,2,2,'CS','mandatory'),
  ('CS412', 'إنترنت الأشياء',                  'Internet of Things (IOT)',                    3,2,2,'CS','mandatory'),
  ('CS413', 'حل المشاكل وإتخاذ القرارات',     'Problem Solving and Decision Making',         3,2,2,'CS','mandatory'),
  ('CS414', 'علم البيانات',                    'Data Science',                                3,2,2,'CS','mandatory'),
  ('CS415', 'الحوسبة السحابية',                'Cloud Computing',                             3,2,2,'CS','mandatory'),
  ('CS416', 'المترجمات',                       'Compilers',                                   3,2,2,'CS','mandatory')
ON CONFLICT (code) DO UPDATE SET
  name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
  credits = EXCLUDED.credits, lecture_hours = EXCLUDED.lecture_hours,
  lab_hours = EXCLUDED.lab_hours;

-- ---- CS Program — Electives ---------------------------------
INSERT INTO curriculum_plans (code, name_ar, name_en, credits, lecture_hours, lab_hours, department, course_type)
VALUES
  ('CS321','علم التشفير',                          'Cryptography',                               3,2,2,'CS','elective'),
  ('CS322','أمن الشبكات والإنترنت',               'Network And Internet Security',              3,2,2,'CS','elective'),
  ('CS423','الحوسبة المتنقلة',                    'Mobile Computing',                           3,2,2,'CS','elective'),
  ('CS424','برمجة تطبيقات المحمول',               'Mobile Application Programming',            3,2,2,'CS','elective'),
  ('CS331','تفاعل الإنسان مع الحاسب',             'Human Computer Interaction',                3,2,2,'CS','elective'),
  ('CS332','أكتشاف المعرفة',                      'Knowledge Discovery',                        3,2,2,'CS','elective'),
  ('CS433','موضوعات مختارة في الذكاء الاصطناعي', 'Selected Topics in Artificial Intelligence',3,2,2,'CS','elective'),
  ('CS434','الحوسبة عالية الأداء',                'High Performance Computing',                3,2,2,'CS','elective'),
  ('IS351','معالجة البيانات والتحليل',            'Data Processing and Analysis',              3,2,2,'CS','elective'),
  ('CS342','نماذج البيانات والتصور',               'Data Models and Visualization',             3,2,2,'CS','elective'),
  ('CS443','معالجة اللغات الطبيعية',              'Natural Language Processing',               3,2,2,'CS','elective'),
  ('IS444','موضوعات مختارة في نظم المعلومات المتقدمة','Selected Topics in Advanced IS',       3,2,2,'CS','elective'),
  ('PR411','مشروع التخرج (1)',                    'Graduation Project (1)',                     3,2,2,'CS','mandatory'),
  ('PR412','مشروع التخرج (2)',                    'Graduation Project (2)',                     3,2,2,'CS','mandatory')
ON CONFLICT (code) DO UPDATE SET
  name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
  credits = EXCLUDED.credits, lecture_hours = EXCLUDED.lecture_hours,
  lab_hours = EXCLUDED.lab_hours;

-- ---- IS Program — Mandatory Applied (48h) -------------------
INSERT INTO curriculum_plans (code, name_ar, name_en, credits, lecture_hours, lab_hours, department, course_type)
VALUES
  ('IS312','نظم إدارة قواعد البيانات',         'Database Management Systems',                3,2,2,'IS','mandatory'),
  ('IS313','إدارة ومعالجة الملفات',            'File Management and Processing',             3,2,2,'IS','mandatory'),
  ('IS314','إسترجاع المعلومات',               'Information Retrieval',                      3,2,2,'IS','mandatory'),
  ('IS315','مستودع البيانات',                  'Data Warehousing',                           3,2,2,'IS','mandatory'),
  ('IS316','تحليل البيانات وإدارتها',          'Data Analytics and Management',             3,2,2,'IS','mandatory'),
  ('IS317','تطوير نظم المعلومات المستندة إلى الويب','Web-based Information Systems Development',3,2,2,'IS','mandatory'),
  ('IS411','التنقيب في البيانات',              'Data Mining',                                3,2,2,'IS','mandatory'),
  ('IS412','إدارة مشاريع نظم المعلومات',       'Information Systems Project Management',    3,2,2,'IS','mandatory'),
  ('IS413','موضوعات مختارة في نظم المعلومات 1','Selected Topics in Information Systems 1', 3,2,2,'IS','mandatory'),
  ('IS414','موضوعات مختارة في قواعد البيانات', 'Selected Topics in Databases',             3,2,2,'IS','mandatory'),
  ('IS415','منهجيات تطوير نظم المعلومات',      'Information Systems Development Methodologies',3,2,2,'IS','mandatory')
ON CONFLICT (code) DO UPDATE SET
  name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
  credits = EXCLUDED.credits, lecture_hours = EXCLUDED.lecture_hours,
  lab_hours = EXCLUDED.lab_hours;

-- ---- IS Program — Electives ---------------------------------
INSERT INTO curriculum_plans (code, name_ar, name_en, credits, lecture_hours, lab_hours, department, course_type)
VALUES
  ('IS321','موضوعات مختارة في هندسة البيانات',         'Selected Topics in Data Engineering',        3,2,2,'IS','elective'),
  ('IS322','قواعد البيانات السحابية',                   'Cloud Databases',                            3,2,2,'IS','elective'),
  ('IS423','قواعد البيانات الموزعة',                    'Distributed Databases',                      3,2,2,'IS','elective'),
  ('IS424','موضوعات مختارة في نظم المعلومات المتقدمة','Selected Topics in Advanced IS',             3,2,2,'IS','elective'),
  ('IS331','نظم معلومات المؤسسية',                      'Enterprise Information Systems',             3,2,2,'IS','elective'),
  ('IS332','نظم المعلومات الإدارية',                    'Management Information Systems',             3,2,2,'IS','elective'),
  ('IS433','الأعمال الإلكترونية',                       'E-Business',                                 3,2,2,'IS','elective'),
  ('IS434','إدارة إجراءات الأعمال',                     'Business Process Management',                3,2,2,'IS','elective'),
  ('IS341','ضمان جودة نظم المعلومات',                   'Information Systems Quality Assurance',      3,2,2,'IS','elective'),
  ('IS342','أمن وإدارة مخاطر نظم المعلومات',           'IS Security and Risk Management',            3,2,2,'IS','elective'),
  ('IS443','مراجعة ورقابة نظم المعلومات',               'Information Systems Audit and Control',      3,2,2,'IS','elective'),
  ('IS452','موضوعات مختارة في نظم المعلومات المتقدمة 2','Advanced Selected Topics in IS 2',          3,2,2,'IS','elective'),
  ('PR421','مشروع التخرج (1)',                          'Graduation Project (1)',                     3,2,2,'IS','mandatory'),
  ('PR422','مشروع التخرج (2)',                          'Graduation Project (2)',                     3,2,2,'IS','mandatory')
ON CONFLICT (code) DO UPDATE SET
  name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
  credits = EXCLUDED.credits, lecture_hours = EXCLUDED.lecture_hours,
  lab_hours = EXCLUDED.lab_hours;

-- ---- IT Program — Mandatory Applied (48h) -------------------
INSERT INTO curriculum_plans (code, name_ar, name_en, credits, lecture_hours, lab_hours, department, course_type)
VALUES
  ('IT312','التعرف على الأنماط',                   'Pattern Recognition',                  3,2,2,'IT','mandatory'),
  ('IT313','تأمين شبكات الحاسبات والمعلومات',     'Information and Computer Networks Security',3,2,2,'IT','mandatory'),
  ('IT314','أشارات ونظم',                          'Signals and Systems',                  3,2,2,'IT','mandatory'),
  ('IT315','المعالجات الدقيقة',                    'Microprocessors',                      3,2,2,'IT','mandatory'),
  ('IT316','معالجة الصور',                          'Image Processing',                     3,2,2,'IT','mandatory'),
  ('IT317','شبكات الحاسب المتقدم',                 'Advanced Computer Networks',           3,2,2,'IT','mandatory'),
  ('IT318','بنية الحاسبات',                        'Computer Architecture',                3,2,2,'IT','mandatory'),
  ('IT319','الوسائط المتعددة الرقمية',             'Digital Multimedia',                   3,2,2,'IT','mandatory'),
  ('IT411','أنظمة الروبوت',                        'Robot Systems',                        3,2,2,'IT','mandatory'),
  ('IT413','تكنولوجيا الاتصالات',                 'Communication Technology',             3,2,2,'IT','mandatory'),
  ('IT414','الأمن السيبراني',                      'Cyber Security',                       3,2,2,'IT','mandatory'),
  ('IT415','شبكات الحوسبة السحابية',               'Cloud Computing Networks',             3,2,2,'IT','mandatory')
ON CONFLICT (code) DO UPDATE SET
  name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
  credits = EXCLUDED.credits, lecture_hours = EXCLUDED.lecture_hours,
  lab_hours = EXCLUDED.lab_hours;

-- ---- IT Program — Electives ---------------------------------
INSERT INTO curriculum_plans (code, name_ar, name_en, credits, lecture_hours, lab_hours, department, course_type)
VALUES
  ('IT321','نظم تشغيل الشبكات',                            'Network Operating System',                     3,2,2,'IT','elective'),
  ('IT322','تكنولوجيا سلسلة الكتل',                        'Blockchain Technology',                        3,2,2,'IT','elective'),
  ('IT423','شبكات المحمول',                                 'Mobile Networks',                              3,2,2,'IT','elective'),
  ('IT424','موضوعات مختارة في شبكات الحاسب',              'Selected Topics in Computer Networks',         3,2,2,'IT','elective'),
  ('IT331','الأنظمة المدمجة',                              'Embedded Systems',                             3,2,2,'IT','elective'),
  ('IT332','تصور الآلة',                                   'Machine Vision',                               3,2,2,'IT','elective'),
  ('IT433','التعرف على الأنماط المتقدمة',                  'Advanced Pattern Recognition',                 3,2,2,'IT','elective'),
  ('IT434','موضوعات مختارة في النظم المدمجة والإنسان الآلي','Selected Topics in Embedded Systems & Robotic',3,2,2,'IT','elective'),
  ('IT341','الرسوم الحاسوبية المتحركة',                    'Computer Animation',                           3,2,2,'IT','elective'),
  ('IT342','الرسم بالحاسب المتقدم',                        'Advanced Computer Graphics',                   3,2,2,'IT','elective'),
  ('IT443','معالجة الصور المتقدمة',                        'Advanced Image Processing',                    3,2,2,'IT','elective'),
  ('IT444','موضوعات مختارة في الوسائط المتعددة',           'Selected Topics in Multimedia',                3,2,2,'IT','elective'),
  ('PR431','مشروع التخرج (1)',                             'Graduation Project (1)',                       3,2,2,'IT','mandatory'),
  ('PR432','مشروع التخرج (2)',                             'Graduation Project (2)',                       3,2,2,'IT','mandatory')
ON CONFLICT (code) DO UPDATE SET
  name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
  credits = EXCLUDED.credits, lecture_hours = EXCLUDED.lecture_hours,
  lab_hours = EXCLUDED.lab_hours;

-- ---- SE Program — Mandatory Applied (48h) -------------------
INSERT INTO curriculum_plans (code, name_ar, name_en, credits, lecture_hours, lab_hours, department, course_type)
VALUES
  ('SE311','تحليل متطلبات البرمجيات',         'Software Requirements Analysis',                           3,2,2,'SE','mandatory'),
  ('SE312','هندسة البرمجيات لتطبيقات الإنترنت','Software Engineering for Internet Applications',          3,2,2,'SE','mandatory'),
  ('SE313','تصميم وعمارة البرمجيات',          'Software Design and Architecture',                         3,2,2,'SE','mandatory'),
  ('SE314','ضمان جودة البرمجيات',             'Software Quality Assurance',                               3,2,2,'SE','mandatory'),
  ('SE316','تصميم واجهات المستخدم',           'User Interface Design',                                    3,2,2,'SE','mandatory'),
  ('SE411','إدارة مشاريع البرمجيات',          'Software Project Management',                              3,2,2,'SE','mandatory'),
  ('SE412','الإختبار والتحقق من البرمجيات',   'Software Testing and Validation',                          3,2,2,'SE','mandatory'),
  ('SE413','أسلوب هندسة البرمجيات في HCI',   'SE Approach to Human Computer Interaction',                3,2,2,'SE','mandatory'),
  ('SE414','إعادة استخدام البرمجيات',         'Software Reuse',                                           3,2,2,'SE','mandatory'),
  ('SE415','الأخلاقيات والممارسة المهنية',   'Ethics and Professional Practice in SE',                   3,2,2,'SE','mandatory'),
  ('SE416','تطوير البرمجيات وصيانتها',        'Software Evolution and Maintenance',                       3,2,2,'SE','mandatory'),
  ('SE417','تصميم برمجيات الأنظمة المدمجة',  'Embedded Systems Software Design',                         3,2,2,'SE','mandatory')
ON CONFLICT (code) DO UPDATE SET
  name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
  credits = EXCLUDED.credits, lecture_hours = EXCLUDED.lecture_hours,
  lab_hours = EXCLUDED.lab_hours;

-- ---- SE Program — Electives ---------------------------------
INSERT INTO curriculum_plans (code, name_ar, name_en, credits, lecture_hours, lab_hours, department, course_type)
VALUES
  ('SE321','أمن البرمجيات',                        'Software Security',                          3,2,2,'SE','elective'),
  ('SE322','أنماط التصميم',                         'Design Patterns',                            3,2,2,'SE','elective'),
  ('SE423','هندسة استخدام البرمجيات',               'Software Usability Engineering',             3,2,2,'SE','elective'),
  ('SE424','التطبيقات المتنقلة',                    'Mobile Applications',                        3,2,2,'SE','elective'),
  ('SE331','إدارة تطوير البرمجيات',                 'Software Development Management',            3,2,2,'SE','elective'),
  ('SE332','تطوير تطبيقات الويب',                   'Web Application Development',                3,2,2,'SE','elective'),
  ('SE433','تطوير الألعاب',                         'Games Development',                          3,2,2,'SE','elective'),
  ('SE434','النمذجة والتصميم ثلاثي الأبعاد',        '3D Modeling and Design',                    3,2,2,'SE','elective'),
  ('SE341','هندسة المعرفة',                         'Knowledge Engineering',                      3,2,2,'SE','elective'),
  ('SE342','إحترافية ممارسة هندسة البرمجيات',       'Professional Software Engineering Practice', 3,2,2,'SE','elective'),
  ('SE443','الطرق الأساسية في هندسة البرمجيات',     'Formal Methods in Software Engineering',    3,2,2,'SE','elective'),
  ('SE444','موضوعات مختارة في هندسة البرمجيات',     'Selected Topics in Software Engineering',   3,2,2,'SE','elective'),
  ('PR441','مشروع التخرج (1)',                      'Graduation Project (1)',                     3,2,2,'SE','mandatory'),
  ('PR442','مشروع التخرج (2)',                      'Graduation Project (2)',                     3,2,2,'SE','mandatory')
ON CONFLICT (code) DO UPDATE SET
  name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
  credits = EXCLUDED.credits, lecture_hours = EXCLUDED.lecture_hours,
  lab_hours = EXCLUDED.lab_hours;


-- ============================================================
-- SECTION 2 — PREREQUISITES
-- 72 relationships from bylaw
-- ============================================================
-- Assumed schema:
--   course_prerequisites(course_code VARCHAR, prerequisite_code VARCHAR,
--                        PRIMARY KEY (course_code, prerequisite_code))
-- ============================================================

-- Clear and re-insert prerequisites for full accuracy
DELETE FROM course_prerequisites WHERE course_code IN (
  'BS113','BS114','BS117',
  'CS211','CS212','IS211','IS212','IT211','IT212','CS213','CS214',
  'IS311','IS312','IS313','IS314','CS311','CS312','CS313','IT311',
  'CS314','CS315','CS316','SE315','IS318','CS411','CS412','CS413',
  'CS414','CS415','CS416',
  'IT312','IT313','IT314','IT315','IT316','IT317','IT318','IT319',
  'IT411','IT413','IT414','IT415',
  'IS315','IS316','IS317','IS411','IS412','IS413','IS414','IS415',
  'SE311','SE312','SE313','SE314','SE316','SE411','SE412','SE413',
  'SE414','SE416','SE417',
  'CS321','CS322','CS423','CS424','CS331','CS332','CS433','CS434',
  'IS351','CS342','CS443','IS444',
  'IT321','IT322','IT423','IT424','IT332','IT433','IT434','IT342','IT443','IT444',
  'IS321','IS322','IS331','IS332','IS433','IS434','IS342','IS443',
  'SE322','SE423','SE424','SE332','SE433','SE434','SE342','SE443','SE444',
  'UNV121','PR412','PR422','PR432','PR442'
);

INSERT INTO course_prerequisites (course_code, prerequisite_code) VALUES
-- College Math
  ('BS113','BS111'), ('BS114','BS113'),
  ('BS117','BS111'), ('BS117','BS116'),
-- College CS
  ('CS211','CS112'), ('CS212','CS112'),
  ('IS211','IS111'),
  ('IS212','BS113'), ('IS212','BS112'),
  ('IT211','BS115'),
  ('IT212','CS111'),
  ('CS213','CS212'), ('CS214','CS212'),
-- CS mandatory
  ('IS311','IS211'),
  ('CS311','IT212'),
  ('CS312','IT211'),
  ('CS313','CS212'),
  ('IT311','CS112'),
  ('CS314','CS211'),
  ('CS315','IS311'),
  ('CS316','CS214'),
  ('SE315','SE211'),
  ('IS318','BS116'),
  ('CS411','BS112'),
  ('CS412','IT212'),
  ('CS413','CS213'),
  ('CS414','CS314'),
  ('CS415','CS316'),
  ('CS416','CS411'),
-- CS electives
  ('CS321','CS311'), ('CS322','CS311'),
  ('CS423','CS316'), ('CS424','CS423'),
  ('CS331','CS213'), ('CS332','CS331'),
  ('CS433','CS313'), ('CS434','CS214'),
  ('IS351','IS311'),
  ('CS342','IS351'),
  ('CS443','CS314'),
  ('IS444','IS351'),
  ('PR412','PR411'),
-- IS mandatory
  ('IS312','IS211'), ('IS313','CS212'),
  ('IS314','BS115'),
  ('IS315','IS311'), ('IS316','IS315'),
  ('IS317','CS211'),
  ('IS411','BS116'), ('IS412','IS311'),
  ('IS413','IS317'), ('IS414','IS312'),
  ('IS415','IS311'),
-- IS electives
  ('IS321','IS311'), ('IS322','IS312'),
  ('IS423','IS211'),
  ('IS424','IS311'),
  ('IS331','IS317'), ('IS332','IS412'),
  ('IS433','IS332'), ('IS434','IS412'),
  ('IS341','IS111'), ('IS342','IS313'),
  ('IS443','IS311'),
  ('CS342','IS351'), ('CS443','CS314'),
  ('PR422','PR421'),
-- IT mandatory
  ('IT312','BS117'),
  ('IT313','IT111'),
  ('IT314','BS114'),
  ('IT315','IT211'),
  ('IT316','IT314'),
  ('IT317','IT212'),
  ('IT318','BS115'),
  ('IT319','IT311'),
  ('IT411','IT315'),
  ('IT413','IT317'),
  ('IT414','IT313'),
  ('IT415','IT111'),
  ('CS412','IT212'),
-- IT electives
  ('IT321','CS214'),
  ('IT322','IT111'),
  ('IT423','IT321'),
  ('IT424','IT317'),
  ('IT331','BS115'),
  ('IT332','IT315'),
  ('IT433','IT312'),
  ('IT434','IT331'),
  ('IT341','CS111'),
  ('IT342','IT341'),
  ('IT443','IT316'),
  ('IT444','IT319'),
  ('PR432','PR431'),
-- SE mandatory
  ('SE311','SE211'), ('SE312','SE211'),
  ('SE313','SE311'), ('SE314','SE311'),
  ('SE316','SE312'),
  ('SE411','SE314'), ('SE412','SE314'),
  ('SE413','SE315'),
  ('SE414','SE313'),
  ('SE416','SE412'), ('SE417','SE411'),
-- SE electives
  ('SE321','SE211'), ('SE322','SE321'),
  ('SE423','SE322'), ('SE424','SE423'),
  ('SE331','SE211'), ('SE332','SE331'),
  ('SE433','SE332'), ('SE434','SE433'),
  ('SE341','CS211'), ('SE342','SE341'),
  ('SE443','SE342'), ('SE444','SE443'),
  ('PR442','PR441'),
-- University
  ('UNV121','UNV113')
ON CONFLICT DO NOTHING;


-- ============================================================
-- SECTION 3 — CRITICAL BUG FIX  (FIX-001)
-- IT317 (Advanced Computer Networks) was incorrectly assigned
-- to Dr. Marian Wagdy. Her section should be IT212
-- (Computer Network Technology).
--
-- From info.pdf: IT212 is scheduled for Dr. Marian Wagdy in
-- Year 2, Term 2 (Tuesday 9:00-11:00, Central Hall Upper).
-- The duplicate IT317 entry for Dr. Marian must be removed
-- or corrected to IT212.
-- ============================================================

DO $$
DECLARE
  v_marian_id    INT;
  v_it212_id     INT;
  v_bad_offering INT;
BEGIN

  -- 1. Resolve Dr. Marian Wagdy's user id
  SELECT id INTO v_marian_id
  FROM users
  WHERE name_ar ILIKE '%مريان%'
     OR name_ar ILIKE '%مريان وجدي%'
     OR name_en ILIKE '%marian%'
  LIMIT 1;

  IF v_marian_id IS NULL THEN
    RAISE NOTICE 'FIX-001: Could not locate Dr. Marian Wagdy in users table — fix skipped. Check name spelling.';
    RETURN;
  END IF;

  -- 2. Find the wrongly-coded IT317 offering assigned to Dr. Marian
  SELECT co.id INTO v_bad_offering
  FROM course_offerings co
  JOIN courses c ON c.id = co.course_id
  WHERE c.code = 'IT317'
    AND co.doctor_id = (SELECT id FROM doctors WHERE user_id = v_marian_id LIMIT 1)
  LIMIT 1;

  IF v_bad_offering IS NULL THEN
    RAISE NOTICE 'FIX-001: No IT317 offering found for Dr. Marian Wagdy — already fixed or offering does not exist.';
    RETURN;
  END IF;

  -- 3. Check whether a correct IT212 offering already exists for her
  SELECT co.id INTO v_it212_id
  FROM course_offerings co
  JOIN courses c ON c.id = co.course_id
  WHERE c.code = 'IT212'
    AND co.doctor_id = (SELECT id FROM doctors WHERE user_id = v_marian_id LIMIT 1)
  LIMIT 1;

  IF v_it212_id IS NOT NULL THEN
    -- IT212 already exists — just delete the stray IT317 row
    RAISE NOTICE 'FIX-001: IT212 offering for Dr. Marian already exists (id=%). Deleting stray IT317 offering (id=%).', v_it212_id, v_bad_offering;
    DELETE FROM course_offerings WHERE id = v_bad_offering;
  ELSE
    -- Rename the stray IT317 row to IT212
    RAISE NOTICE 'FIX-001: Renaming course_offering id=% from IT317 → IT212 for Dr. Marian Wagdy.', v_bad_offering;
    UPDATE course_offerings
    SET course_id = (SELECT id FROM courses WHERE code = 'IT212')
    WHERE id = v_bad_offering;
  END IF;

  -- 4. Fix the schedule slot if the table exists
  BEGIN
    UPDATE doctor_schedule_slots
    SET course_code = 'IT212'
    WHERE doctor_id = v_marian_id
      AND course_code = 'IT317';
    RAISE NOTICE 'FIX-001: doctor_schedule_slots updated for Dr. Marian.';
  EXCEPTION WHEN undefined_column THEN
    RAISE NOTICE 'FIX-001: doctor_schedule_slots table does not have course_code — skipped.';
  WHEN undefined_table THEN
    RAISE NOTICE 'FIX-001: doctor_schedule_slots table not found — skipped.';
  END;

  RAISE NOTICE 'FIX-001: COMPLETE — IT317 duplicate removed, Dr. Marian now correctly holds IT212.';
END $$;


-- ============================================================
-- SECTION 4 — SCHEDULE SEED (doctor_schedule_slots)
-- From info.pdf — all corrected assignments
-- ============================================================
-- Assumed schema:
--   doctor_schedule_slots(
--     id          SERIAL PRIMARY KEY,
--     doctor_id   INT REFERENCES users(id),
--     course_code VARCHAR,
--     year_level  INT,
--     department  VARCHAR,   -- 'ALL','CS','IS','IT','SE'
--     term        INT,       -- 1 or 2
--     day_of_week VARCHAR,
--     start_time  TIME,
--     end_time    TIME,
--     room        VARCHAR,
--     mode        VARCHAR    -- 'online','in-person'
--   )
-- ============================================================
-- Helper: resolve doctor IDs by Arabic name fragment
-- Run this block first to verify doctor IDs match your data:
-- SELECT id, name_ar, name_en FROM users WHERE role='doctor' ORDER BY name_ar;

-- Clear current slots and re-seed from corrected data
TRUNCATE doctor_schedule_slots RESTART IDENTITY CASCADE;

-- We use a sub-select to resolve doctor id by name.
-- Adjust the ILIKE patterns if names are stored differently in your DB.

INSERT INTO doctor_schedule_slots
  (doctor_id, course_code, year_level, department, term, day_of_week, start_time, end_time, room, mode)
SELECT u.id, s.course_code, s.year_level, s.department, s.term,
       s.day_of_week, s.start_time::TIME, s.end_time::TIME, s.room, s.mode
FROM (VALUES
-- ── YEAR 1 ─ TERM 1 ──────────────────────────────────────
  ('%مايدة%',    'BS112',  1,'ALL',1,'السبت',   '09:00','11:00','المدرج المركزي العلوي','in-person'),
  ('%مسامة%',   'CS111',  1,'ALL',1,'الأحد',    '11:00','13:00','Online',               'online'),
  ('%منية%',    'IS111',  1,'ALL',1,'الأحد',    '07:00','09:00','Online',               'online'),
  ('%نانسي%',    'BS111',  1,'ALL',1,'الاثنين',  '11:00','13:00','Online',               'online'),
  ('%شيماء%',   'BS116',  1,'ALL',1,'الاثنين',  '09:00','11:00','المدرج المركزي العلوي','in-person'),
  ('%وليد سمير%','UNV113', 1,'ALL',1,'الاثنين',  '13:00','15:00','Online',               'online'),
-- ── YEAR 1 ─ TERM 2 ──────────────────────────────────────
  ('%مايدة%',   'BS115',  1,'ALL',2,'السبت',    '07:00','09:00','Online',               'online'),
  ('%أحمد سليم%','UNV120', 1,'ALL',2,'السبت',    '11:00','13:00','Online',               'online'),
  ('%مصطفى%',   'BS113',  1,'ALL',2,'الأحد',    '11:00','13:00','المدرج المركزي العلوي','in-person'),
  ('%نانسي%',    'BS115',  1,'ALL',2,'الاثنين',  '09:00','11:00','المدرج المركزي العلوي','in-person'),
  ('%أروه أبو%', 'UNV114', 1,'ALL',2,'الثلاثاء', '07:00','09:00','Online',               'online'),
  ('%شيماء%',   'UNV111', 1,'ALL',2,'الأربعاء', '07:00','09:00','Online',               'online'),
  ('%مسامة%',   'CS112',  1,'ALL',2,'الأربعاء', '11:00','13:00','المدرج المركزي العلوي','in-person'),
-- ── YEAR 2 ─ TERM 1 ──────────────────────────────────────
  ('%هناء عبد الهادي%','BS114',2,'ALL',1,'السبت',  '07:00','09:00','Online',               'online'),
  ('%نانسي%',   'BS117',  2,'ALL',1,'السبت',    '13:00','15:00','Online',               'online'),
  ('%مسامة%',   'CS211',  2,'ALL',1,'الثلاثاء', '11:00','13:00','المدرج المركزي العلوي','in-person'),
  ('%أروه أبو%', 'SE211',  2,'ALL',1,'الأربعاء', '11:00','13:00','المدرج المركزي العلوي','in-person'),
  ('%مصطفى%',   'CS212',  2,'ALL',1,'الخميس',   '07:00','09:00','Online',               'online'),
  ('%مايدة%',   'IT211',  2,'ALL',1,'الخميس',   '13:00','15:00','Online',               'online'),
-- ── YEAR 2 ─ TERM 2 ──────────────────────────────────────
  ('%منية%',    'IS211',  2,'ALL',2,'الأحد',    '07:00','09:00','Online',               'online'),
  ('%هناء عيسى%','CS214', 2,'ALL',2,'الاثنين',  '09:00','11:00','المدرج المركزي العلوي','in-person'),
  ('%مريان%',   'IT212',  2,'ALL',2,'الثلاثاء', '09:00','11:00','المدرج المركزي العلوي','in-person'),  -- FIX-001 correct entry
  ('%نانسي%',   'IS212',  2,'ALL',2,'الثلاثاء', '11:00','13:00','المدرج المركزي العلوي','in-person'),
  ('%مسامة%',   'CS213',  2,'ALL',2,'الخميس',   '11:00','13:00','المدرج المركزي العلوي','in-person'),
-- ── YEAR 3 CS ─ TERM 1 ───────────────────────────────────
  ('%أحمد سليم%','IT311', 3,'CS',1,'الأحد',    '07:00','09:00','Online',               'online'),   -- ISSUE-002: conflict with CS313 same slot
  ('%أحمد سليم%','CS313', 3,'CS',1,'الأحد',    '07:00','09:00','Online',               'online'),   -- ISSUE-002: conflict with IT311 same slot
  ('%مصطفى%',   'CS311',  3,'CS',1,'الاثنين',  '09:00','11:00','المدرج المركزي العلوي','in-person'),
  ('%شيماء%',   'IS311',  3,'CS',1,'الاثنين',  '11:00','13:00','المدرج المركزي السفلي','in-person'),
  ('%وليد عبد الخالق%','CS312',3,'CS',1,'الأربعاء','11:00','13:00','Online',            'online'),
  ('%مسامة%',   'CS331',  3,'CS',1,'الخميس',   '11:00','13:00','Online',               'online'),
-- ── YEAR 3 CS ─ TERM 2 ───────────────────────────────────
  ('%وليد عبد الخالق%','CS314',3,'CS',2,'السبت', '11:00','13:00','Online',              'online'),
  ('%أحمد سليم%','CS332', 3,'CS',2,'الأربعاء', '07:00','09:00','Online',               'online'),
  ('%مصطفى%',   'CS411',  3,'CS',2,'الأربعاء', '09:00','11:00','المدرج المركزي العلوي','in-person'),
  ('%أروه أبو%', 'SE315',  3,'CS',2,'الأربعاء', '11:00','13:00','المدرج المركزي العلوي','in-person'),
  ('%وليد عبد الخالق%','CS315',3,'CS',2,'الخميس','07:00','09:00','Online',              'online'),
  ('%أحمد سليم%','CS316', 3,'CS',2,'الخميس',   '07:00','09:00','المدرج المركزي العلوي','in-person'),
-- ── YEAR 3 IT ─ TERM 1 ───────────────────────────────────
  ('%أحمد سليم%','IT311', 3,'IT',1,'الأحد',    '11:00','13:00','Online',               'online'),
  ('%هاني%',    'IT321',  3,'IT',1,'الاثنين',  NULL,   NULL,   'Online',               'online'),   -- time TBD
  ('%أحمد سليم%','CS313', 3,'IT',1,'الثلاثاء', '11:00','13:00','Online',               'online'),
  ('%تهاني%',   'IT315',  3,'IT',1,'الأربعاء', '07:00','09:00','Online',               'online'),
  ('%مريان%',   'IT312',  3,'IT',1,'الخميس',   '07:00','09:00','Online',               'online'),
  ('%مايدة%',   'IT314',  3,'IT',1,'الخميس',   '09:00','11:00','مدرج 2',               'in-person'),
-- ── YEAR 3 IT ─ TERM 2 ───────────────────────────────────
  ('%مريان%',   'IT319',  3,'IT',2,'الأحد',    '09:00','11:00','المدرج المركزي العلوي','in-person'),
  ('%مايدة%',   'IT322',  3,'IT',2,'الأحد',    '11:00','13:00','مدرج 3',               'in-person'),
  ('%أروه أبو%', 'IT318',  3,'IT',2,'الاثنين',  '11:00','13:00','Online',               'online'),
  ('%تهاني%',   'IT317',  3,'IT',2,'الخميس',   '07:00','09:00','Online',               'online'),   -- FIX-001: ONLY Dr. Tahani for IT317
  ('%مريان%',   'IT316',  3,'IT',2,'الخميس',   '15:00','17:00','Online',               'online'),
-- ── YEAR 3 IS ─ TERM 1 ───────────────────────────────────
  ('%أحمد سليم%','CS315', 3,'IS',1,'الأحد',    '09:00','11:00','مدرج 3',               'in-person'),
  ('%هاني%',    'IS313',  3,'IS',1,'الأحد',    '11:00','13:00','مدرج 3',               'in-person'),
  ('%شيماء%',   'IS311',  3,'IS',1,'الأحد',    '11:00','13:00','المدرج المركزي السفلي','in-person'),
  ('%شيماء%',   'IS312',  3,'IS',1,'الاثنين',  '09:00','11:00','مدرج 1',               'in-person'),
  ('%أحمد سليم%','CS313', 3,'IS',1,'الثلاثاء', '07:00','09:00','Online',               'online'),
  ('%منية%',    'IS351',  3,'IS',1,'الثلاثاء', '09:00','11:00','مدرج 2',               'in-person'),
-- ── YEAR 3 IS ─ TERM 2 ───────────────────────────────────
  ('%شيماء%',   'IS315',  3,'IS',2,'السبت',    '07:00','09:00','Online',               'online'),
  ('%إبراهيم%', 'IS317',  3,'IS',2,'الأحد',    '07:00','09:00','Online',               'online'),
  ('%شيماء%',   'IS413',  3,'IS',2,'الثلاثاء', '07:00','09:00','Online',               'online'),
  ('%منية%',    'IS318',  3,'IS',2,'الثلاثاء', '11:00','13:00','Online',               'online'),
  ('%منية%',    'IS314',  3,'IS',2,'الأربعاء', '07:00','09:00','Online',               'online'),
  ('%هاني%',    'IS321',  3,'IS',2,'الخميس',   '11:00','13:00','مدرج 3',               'in-person'),
-- ── YEAR 4 CS ─ TERM 1 ───────────────────────────────────
  ('%وليد عبد الخالق%','CS315',4,'CS',1,'السبت',   '09:00','11:00','المدرج المركزي السفلي','in-person'),
  ('%مريان%',   'CS443',  4,'CS',1,'السبت',    '11:00','13:00','المدرج المركزي العلوي','in-person'),
  ('%أحمد سليم%','SE321', 4,'CS',1,'الأحد',    '09:00','11:00','المدرج المركزي السفلي','in-person'),
  ('%وليد عبد الخالق%','CS434',4,'CS',1,'الاثنين','09:00','11:00','المدرج المركزي السفلي','in-person'),
-- ── YEAR 4 CS ─ TERM 2 ───────────────────────────────────
  ('%هناء عبد الهادي%','CS331',4,'CS',2,'السبت', '07:00','09:00','المدرج المركزي العلوي','in-person'),
  ('%أحمد سليم%','CS332', 4,'CS',2,'الأحد',    '07:00','09:00','المدرج المركزي العلوي','in-person'),
  ('%هناء عبد الهادي%','CS416',4,'CS',2,'الاثنين','07:00','09:00','المدرج المركزي العلوي','in-person'),
  ('%وليد عبد الخالق%','CS415',4,'CS',2,'الاثنين','11:00','13:00','Online',             'online'),
  ('%مصطفى%',   'CS433',  4,'CS',2,'الثلاثاء', NULL,   NULL,   'Online',               'online'),   -- time TBD
-- ── YEAR 4 IT ─ TERM 1 ───────────────────────────────────
  ('%أروه عصام%','IT415', 4,'IT',1,'السبت',    '07:00','09:00','Online',               'online'),
  ('%وليد عبد الخالق%','CS315',4,'IT',1,'الأحد','09:00','11:00','المدرج المركزي السفلي','in-person'),
  ('%مايدة%',   'IT313',  4,'IT',1,'الأربعاء', '09:00','11:00','المدرج المركزي العلوي','in-person'),
-- ── YEAR 4 IT ─ TERM 2 ───────────────────────────────────
  ('%مريان%',   'IT319',  4,'IT',2,'الأحد',    '09:00','11:00','المدرج المركزي العلوي','in-person'),
  ('%مايدة%',   'IT414',  4,'IT',2,'الاثنين',  '09:00','11:00','مدرج 2',               'in-person'),
  ('%أروه أبو%', 'IT413',  4,'IT',2,'الثلاثاء', '11:00','13:00','مدرج 3',               'in-person'),
  ('%ميمان%',   'IT411',  4,'IT',2,'الأربعاء', '09:00','11:00','مدرج 2',               'in-person'),
-- ── YEAR 4 IS ─ TERM 1 ───────────────────────────────────
  ('%إبراهيم%', 'IS341',  4,'IS',1,'السبت',    '07:00','09:00','Online',               'online'),
  ('%شيماء%',   'IS411',  4,'IS',1,'السبت',    '07:00','09:00','مدرج 3',               'in-person'),
  ('%هاني%',    'IS412',  4,'IS',1,'السبت',    '11:00','13:00','مدرج 1',               'in-person'),
  ('%منية%',    'IS351',  4,'IS',1,'الأحد',    '09:00','11:00','مدرج 2',               'in-person'),
-- ── YEAR 4 IS ─ TERM 2 ───────────────────────────────────
  ('%شيماء%',   'IS342',  4,'IS',2,'الاثنين',  '09:00','11:00','مدرج 1',               'in-person'),
  ('%شيماء%',   'IS414',  4,'IS',2,'الثلاثاء', '09:00','11:00','مدرج 3',               'in-person'),
  ('%هاني%',    'IS321',  4,'IS',2,'الخميس',   '11:00','13:00','مدرج 3',               'in-person')
) AS s(name_pat, course_code, year_level, department, term, day_of_week, start_time, end_time, room, mode)
JOIN users u ON u.name_ar ILIKE s.name_pat AND u.role = 'doctor'
ON CONFLICT DO NOTHING;


-- ============================================================
-- SECTION 5 — AUDIT NOTE
-- ============================================================

INSERT INTO audit_logs (action, entity_type, entity_id, performed_by, details, created_at)
SELECT
  'DATA_PATCH',
  'curriculum',
  0,
  (SELECT id FROM users WHERE role = 'admin' LIMIT 1),
  jsonb_build_object(
    'patch_date',   '2026-05-27',
    'source_files', ARRAY['bylaw-2024-7-73-14-33.pdf','info.pdf'],
    'fixes_applied',ARRAY['FIX-001: IT317→IT212 for Dr. Marian Wagdy'],
    'issues_flagged',ARRAY[
      'ISSUE-002: IT311/CS313 scheduling conflict Y3-CS-T1',
      'ISSUE-003: Unmatched course (Microcontrollers) Y4-IT-T1',
      'ISSUE-004: Unmatched course (Virtual Reality) Y4-IT-T1',
      'ISSUE-005: Unmatched course (Digital Signal Processing) Y4-IT-T2',
      'ISSUE-006: Unmatched course (Computer Languages Concepts) Y4-CS-T1',
      'ISSUE-007: Unmatched course (Big Data Mgmt) Y4-IS-T2',
      'ISSUE-008: Unmatched course (Service-Oriented Architecture) Y4-IS-T2'
    ]
  ),
  NOW()
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'audit_logs');

COMMIT;

-- =============================================================================
-- POST-PATCH VERIFICATION QUERIES
-- Run these after applying the patch to confirm correctness.
-- =============================================================================

-- 1. Confirm IT317 belongs to Dr. Tahani only:
-- SELECT co.course_code, u.name_ar, co.max_seats
-- FROM course_offerings co
-- JOIN users u ON u.id = co.doctor_id
-- WHERE co.course_code IN ('IT212','IT317')
-- ORDER BY co.course_code;

-- 2. Check for any remaining schedule conflicts (same instructor, same time):
-- SELECT doctor_id, day_of_week, start_time, COUNT(*) as cnt
-- FROM doctor_schedule_slots
-- GROUP BY doctor_id, day_of_week, start_time
-- HAVING COUNT(*) > 1;

-- 3. Verify prerequisite count (expect ~72):
-- SELECT COUNT(*) FROM course_prerequisites;

-- 4. Verify course count by department:
-- SELECT department, course_type, COUNT(*) FROM curriculum_plans GROUP BY 1,2 ORDER BY 1,2;
