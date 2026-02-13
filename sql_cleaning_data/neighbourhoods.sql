UPDATE airbnb.neighbourhoods
SET neighbourhood = REGEXP_REPLACE(
        TRIM(INITCAP(LOWER(neighbourhood))),
        E'\\s*-\\s*',
        '-',
        'g');


SELECT * FROM airbnb.neighbourhoods








