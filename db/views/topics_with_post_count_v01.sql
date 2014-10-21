SELECT
  topics.category_id,
  COUNT(*) AS topic_count,
  SUM(topics.posts_count) AS post_count
FROM topics
WHERE topics.deleted_at IS NULL
AND topics.visible = 't'
AND topics.id NOT IN (
  SELECT categories.topic_id
  FROM categories
  WHERE topic_id IS NOT NULL
)
GROUP BY topics.category_id
