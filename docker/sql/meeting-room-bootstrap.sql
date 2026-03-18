SET NAMES utf8mb4;

SET @default_schedule_id := COALESCE(
  (SELECT schedule_id FROM schedules WHERE isdefault = 1 ORDER BY schedule_id LIMIT 1),
  1
);
SET @default_layout_id := COALESCE(
  (SELECT layout_id FROM schedules WHERE schedule_id = @default_schedule_id LIMIT 1),
  1
);

UPDATE layouts
SET timezone = 'Asia/Tokyo'
WHERE layout_id = @default_layout_id;

DELETE FROM time_blocks
WHERE layout_id = @default_layout_id;

INSERT INTO time_blocks (`availability_code`, `layout_id`, `start_time`, `end_time`) VALUES
(2, @default_layout_id, '00:00', '08:00'),
(1, @default_layout_id, '08:00', '08:15'),
(1, @default_layout_id, '08:15', '08:30'),
(1, @default_layout_id, '08:30', '08:45'),
(1, @default_layout_id, '08:45', '09:00'),
(1, @default_layout_id, '09:00', '09:15'),
(1, @default_layout_id, '09:15', '09:30'),
(1, @default_layout_id, '09:30', '09:45'),
(1, @default_layout_id, '09:45', '10:00'),
(1, @default_layout_id, '10:00', '10:15'),
(1, @default_layout_id, '10:15', '10:30'),
(1, @default_layout_id, '10:30', '10:45'),
(1, @default_layout_id, '10:45', '11:00'),
(1, @default_layout_id, '11:00', '11:15'),
(1, @default_layout_id, '11:15', '11:30'),
(1, @default_layout_id, '11:30', '11:45'),
(1, @default_layout_id, '11:45', '12:00'),
(1, @default_layout_id, '12:00', '12:15'),
(1, @default_layout_id, '12:15', '12:30'),
(1, @default_layout_id, '12:30', '12:45'),
(1, @default_layout_id, '12:45', '13:00'),
(1, @default_layout_id, '13:00', '13:15'),
(1, @default_layout_id, '13:15', '13:30'),
(1, @default_layout_id, '13:30', '13:45'),
(1, @default_layout_id, '13:45', '14:00'),
(1, @default_layout_id, '14:00', '14:15'),
(1, @default_layout_id, '14:15', '14:30'),
(1, @default_layout_id, '14:30', '14:45'),
(1, @default_layout_id, '14:45', '15:00'),
(1, @default_layout_id, '15:00', '15:15'),
(1, @default_layout_id, '15:15', '15:30'),
(1, @default_layout_id, '15:30', '15:45'),
(1, @default_layout_id, '15:45', '16:00'),
(1, @default_layout_id, '16:00', '16:15'),
(1, @default_layout_id, '16:15', '16:30'),
(1, @default_layout_id, '16:30', '16:45'),
(1, @default_layout_id, '16:45', '17:00'),
(1, @default_layout_id, '17:00', '17:15'),
(1, @default_layout_id, '17:15', '17:30'),
(1, @default_layout_id, '17:30', '17:45'),
(1, @default_layout_id, '17:45', '18:00'),
(2, @default_layout_id, '18:00', '00:00');

UPDATE schedules
SET
  name = '会議室予約',
  isdefault = 1,
  weekdaystart = 1,
  daysvisible = 7,
  default_layout = 3
WHERE schedule_id = @default_schedule_id;

DELETE FROM time_blocks
WHERE layout_id = @default_layout_id;

INSERT INTO time_blocks (
  layout_id,
  start_time,
  end_time,
  availability_code,
  label,
  day_of_week
)
VALUES
  (@default_layout_id, '00:00:00', '08:00:00', 2, NULL, NULL),
  (@default_layout_id, '18:00:00', '00:00:00', 2, NULL, NULL);

INSERT INTO time_blocks (
  layout_id,
  start_time,
  end_time,
  availability_code,
  label,
  day_of_week
)
WITH RECURSIVE reservable_slots AS (
  SELECT CAST('08:00:00' AS TIME) AS slot_start
  UNION ALL
  SELECT ADDTIME(slot_start, '00:15:00')
  FROM reservable_slots
  WHERE slot_start < '17:45:00'
)
SELECT
  @default_layout_id,
  slot_start,
  ADDTIME(slot_start, '00:15:00'),
  1,
  NULL,
  NULL
FROM reservable_slots;

UPDATE users
SET
  timezone = 'Asia/Tokyo',
  language = 'ja_jp',
  homepageid = 1;

INSERT INTO groups (name)
SELECT '研究室A'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE name = '研究室A');

INSERT INTO groups (name)
SELECT '研究室B'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE name = '研究室B');

INSERT INTO groups (name)
SELECT '研究室C'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE name = '研究室C');

INSERT INTO groups (name)
SELECT '研究室D'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE name = '研究室D');

INSERT INTO groups (name)
SELECT '研究室E'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE name = '研究室E');

UPDATE resources
SET name = 'G1-420 セミナー室（３単位）'
WHERE name = '会議室1'
  AND NOT EXISTS (SELECT 1 FROM resources WHERE name = 'G1-420 セミナー室（３単位）');

UPDATE resources
SET name = 'G1-419 セミナー室（２単位）'
WHERE name = '会議室2'
  AND NOT EXISTS (SELECT 1 FROM resources WHERE name = 'G1-419 セミナー室（２単位）');

UPDATE resources
SET name = 'G1-617 招へい研究者室（１単位）'
WHERE name = '会議室3'
  AND NOT EXISTS (SELECT 1 FROM resources WHERE name = 'G1-617 招へい研究者室（１単位）');

UPDATE resources
SET name = 'G1-813 セミナー室（２単位）'
WHERE name = '会議室4'
  AND NOT EXISTS (SELECT 1 FROM resources WHERE name = 'G1-813 セミナー室（２単位）');

UPDATE resources
SET name = 'G1-820 セミナー室（３単位）'
WHERE name = '会議室5'
  AND NOT EXISTS (SELECT 1 FROM resources WHERE name = 'G1-820 セミナー室（３単位）');

UPDATE resources
SET name = 'G1-821 非常勤講師室（１単位）'
WHERE name = '会議室6'
  AND NOT EXISTS (SELECT 1 FROM resources WHERE name = 'G1-821 非常勤講師室（１単位）');

UPDATE resources
SET name = 'G1-1013 セミナー室（２単位）'
WHERE name = '会議室7'
  AND NOT EXISTS (SELECT 1 FROM resources WHERE name = 'G1-1013 セミナー室（２単位）');

DELETE FROM resources
WHERE name IN ('会議室8', '会議室9', '会議室10');

INSERT INTO resources (
  name,
  location,
  description,
  max_participants,
  autoassign,
  requires_approval,
  allow_multiday_reservations,
  schedule_id
)
SELECT 'G1-420 セミナー室（３単位）', '共用フロア', '研究室共用の会議室', 6, 1, 0, 1, @default_schedule_id
WHERE NOT EXISTS (SELECT 1 FROM resources WHERE name = 'G1-420 セミナー室（３単位）');

INSERT INTO resources (
  name,
  location,
  description,
  max_participants,
  autoassign,
  requires_approval,
  allow_multiday_reservations,
  schedule_id
)
SELECT 'G1-419 セミナー室（２単位）', '共用フロア', '研究室共用の会議室', 6, 1, 0, 1, @default_schedule_id
WHERE NOT EXISTS (SELECT 1 FROM resources WHERE name = 'G1-419 セミナー室（２単位）');

INSERT INTO resources (
  name,
  location,
  description,
  max_participants,
  autoassign,
  requires_approval,
  allow_multiday_reservations,
  schedule_id
)
SELECT 'G1-617 招へい研究者室（１単位）', '共用フロア', '研究室共用の会議室', 8, 1, 0, 1, @default_schedule_id
WHERE NOT EXISTS (SELECT 1 FROM resources WHERE name = 'G1-617 招へい研究者室（１単位）');

INSERT INTO resources (
  name,
  location,
  description,
  max_participants,
  autoassign,
  requires_approval,
  allow_multiday_reservations,
  schedule_id
)
SELECT 'G1-813 セミナー室（２単位）', '共用フロア', '研究室共用の会議室', 8, 1, 0, 1, @default_schedule_id
WHERE NOT EXISTS (SELECT 1 FROM resources WHERE name = 'G1-813 セミナー室（２単位）');

INSERT INTO resources (
  name,
  location,
  description,
  max_participants,
  autoassign,
  requires_approval,
  allow_multiday_reservations,
  schedule_id
)
SELECT 'G1-820 セミナー室（３単位）', '共用フロア', '研究室共用の会議室', 10, 1, 0, 1, @default_schedule_id
WHERE NOT EXISTS (SELECT 1 FROM resources WHERE name = 'G1-820 セミナー室（３単位）');

INSERT INTO resources (
  name,
  location,
  description,
  max_participants,
  autoassign,
  requires_approval,
  allow_multiday_reservations,
  schedule_id
)
SELECT 'G1-821 非常勤講師室（１単位）', '共用フロア', '研究室共用の会議室', 10, 1, 0, 1, @default_schedule_id
WHERE NOT EXISTS (SELECT 1 FROM resources WHERE name = 'G1-821 非常勤講師室（１単位）');

INSERT INTO resources (
  name,
  location,
  description,
  max_participants,
  autoassign,
  requires_approval,
  allow_multiday_reservations,
  schedule_id
)
SELECT 'G1-1013 セミナー室（２単位）', '共用フロア', '研究室共用の会議室', 12, 1, 0, 1, @default_schedule_id
WHERE NOT EXISTS (SELECT 1 FROM resources WHERE name = 'G1-1013 セミナー室（２単位）');

UPDATE resources
SET sort_order = CASE name
  WHEN 'G1-1013 セミナー室（２単位）' THEN 1
  WHEN 'G1-821 非常勤講師室（１単位）' THEN 2
  WHEN 'G1-820 セミナー室（３単位）' THEN 3
  WHEN 'G1-813 セミナー室（２単位）' THEN 4
  WHEN 'G1-617 招へい研究者室（１単位）' THEN 5
  WHEN 'G1-419 セミナー室（２単位）' THEN 6
  WHEN 'G1-420 セミナー室（３単位）' THEN 7
  ELSE sort_order
END
WHERE name IN (
  'G1-1013 セミナー室（２単位）',
  'G1-821 非常勤講師室（１単位）',
  'G1-820 セミナー室（３単位）',
  'G1-813 セミナー室（２単位）',
  'G1-617 招へい研究者室（１単位）',
  'G1-419 セミナー室（２単位）',
  'G1-420 セミナー室（３単位）'
);
