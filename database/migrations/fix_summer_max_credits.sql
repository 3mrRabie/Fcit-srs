-- FIX-L6: Correct summer_max_credits from 7 to 9 to match academic-regulations.json
UPDATE bylaw_config SET value = '9', default_value = '9' WHERE key = 'summer_max_credits';
