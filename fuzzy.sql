/*sql improved implementation of http://forum.aeroion.ru/topic461.html*/
CREATE OR REPLACE FUNCTION vowel_replace(uname TEXT)
RETURNS TEXT AS $$
DECLARE
prev_char text = '';
curr_char text = '';
buffname text = '';
BEGIN
  WHILE 1 <= length(uname) LOOP
    SELECT substr(uname, 1, 1) INTO prev_char;
    SELECT substr(uname, 2, 1) INTO curr_char;
    IF 'ІЇИЄЕЭЁЫЙЬЪЮЯ' like '%'||prev_char||'%' THEN
      IF curr_char = 'А' THEN
        SELECT buffname || 'ІА' INTO buffname;
        SELECT right(uname, length(uname) - 2) INTO uname;
      ELSIF curr_char = 'У' THEN
        SELECT buffname || 'ІУ' INTO buffname;
        SELECT right(uname, length(uname) - 2) INTO uname;
      ELSIF curr_char = 'О' THEN
        SELECT buffname || 'ІО' INTO buffname;
        SELECT right(uname, length(uname) - 2) INTO uname;
      ELSIF curr_char = 'I' THEN
        SELECT buffname || 'І' INTO buffname;
        SELECT right(uname, length(uname) - 2) INTO uname;
      ELSE
        IF 'ІЇИЄЕЭЁЫ' like '%'||prev_char||'%' THEN
          SELECT buffname || 'І' INTO buffname;
        ELSIF 'Ю' like '%'||prev_char||'%' THEN
          SELECT buffname || 'ІУ' INTO buffname;
        ELSIF 'Я' like '%'||prev_char||'%' THEN
          SELECT buffname || 'ІА' INTO buffname;
        END IF;
        SELECT right(uname, length(uname) - 1) INTO uname;
      END IF;
    ELSE
      /*А, О, У or consonant*/
      SELECT buffname || prev_char INTO buffname;
      SELECT right(uname, length(uname) - 1) INTO uname;
    END IF;
  END LOOP;
  RETURN   buffname;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION consonant_replace(uname TEXT)
RETURNS TEXT AS $$
DECLARE
prev_char text = '';
curr_char text = '';
buffname text = '';
BEGIN
  WHILE 1 <= length(uname) LOOP
    SELECT substr(uname, 1, 1) INTO prev_char;
    SELECT substr(uname, 2, 1) INTO curr_char;
    IF ('ОАУІ' NOT like '%'||prev_char||'%') THEN
      IF prev_char = 'Ц' THEN
        SELECT 'С' INTO prev_char;
      ELSIF prev_char = 'Ґ' THEN
        SELECT 'Г' INTO prev_char;
      END IF;

      IF ('ОАУІ' like '%'||curr_char||'%') THEN
        IF prev_char = 'Б' THEN
          SELECT buffname || 'П' INTO buffname;
        ELSIF prev_char = 'З' THEN
          SELECT buffname || 'С' INTO buffname;
        ELSIF prev_char = 'Д' THEN
          SELECT buffname || 'Т' INTO buffname;
        ELSIF prev_char = 'В' THEN
          SELECT buffname || 'Ф' INTO buffname;
        ELSIF prev_char = 'Г' THEN
          SELECT buffname || 'К' INTO buffname;
        ELSE
          SELECT buffname || prev_char INTO buffname;
        END IF;
      ELSIF ('ДТЦC' like '%'||prev_char||'%') and (curr_char = 'С' or curr_char = 'Ц') THEN
        SELECT buffname || 'С' INTO buffname;
      ELSE
        SELECT buffname || prev_char INTO buffname;
        IF NOT ('ОАУІ' like '%'|| curr_char ||'%') THEN
          IF curr_char = 'Ц' THEN
            SELECT 'С' INTO curr_char;
          ELSIF curr_char = 'Ґ' THEN
            SELECT 'Г' INTO curr_char;
          END IF;
          SELECT buffname || curr_char INTO buffname;
        END IF;

      END IF;
      SELECT right(uname, length(uname) - 2) INTO uname;
    ELSE
    SELECT right(uname, length(uname) - 1) INTO uname;
    END IF;

  END LOOP;
  RETURN   buffname;
END;
$$
LANGUAGE plpgsql;
