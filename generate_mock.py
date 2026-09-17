import json

with open(r'd:\Documents\rextra\REXTRA-AI\data\riasec_questions.json', encoding='utf-8') as f:
    d = json.load(f)

dart = 'const mockRiasecQuestions = [\n'
for q in d['questions']:
    safe_text = q['question_text'].replace("'", "\\'")
    dart += f"  {{'id': '{q['code']}', 'pertanyaan': '{safe_text}'}},\n"
dart += '];\n'

with open(r'd:\Documents\rextra\rextra-md\lib\features\kenalidiri\data\riasec_mock.dart', 'w', encoding='utf-8') as f:
    f.write(dart)
