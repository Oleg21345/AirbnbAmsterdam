SELECT COUNT(*) AS bad_names
FROM airbnb.reviews
WHERE reviewer_name <> TRIM(reviewer_name);

SELECT * FROM airbnb.reviews;



UPDATE airbnb.reviews
SET comments = REGEXP_REPLACE(comments, E'<br\\s*/?>', ' ', 'gi')
WHERE comments ~* E'<br\\s*/?>';
