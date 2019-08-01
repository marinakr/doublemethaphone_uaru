CREATE OR REPLACE FUNCTION left_suffix(uname TEXT, n INTEGER)
RETURNS TEXT AS $$
BEGIN
  RETURN left(uname, length(uname) - n);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION known_char(uname TEXT)
RETURNS TEXT AS $$
DECLARE
prev_char text = '';
buffname text = '';
BEGIN
  WHILE 1 <= length(uname) LOOP
  SELECT substr(uname, 1, 1) INTO prev_char;
  IF 'ОЄЕАИУЭЮЯЁЫІЇПСТРКЛМНБВГҐДЖЗЙФХЦЧШЩ' LIKE '%'||prev_char||'%' THEN
  SELECT buffname || prev_char INTO buffname;
  END  IF;
  SELECT right(uname, length(uname) - 1) INTO uname;
END LOOP;
RETURN   buffname;
END;
$$
LANGUAGE plpgsql;


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
    IF 'ІЇИЄЕЭЁЫЙЬЪЮЯ''' like '%'||prev_char||'%' THEN
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
    IF prev_char = 'Ц' THEN
      SELECT 'С' INTO prev_char;
    ELSIF prev_char = 'Ґ' THEN
      SELECT 'Г' INTO prev_char;
    END IF;

    IF ('ОАУІ' NOT like '%'||prev_char||'%') THEN
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
        SELECT right(uname, length(uname) - 2) INTO uname;
      ELSIF ('ДТЦC' like '%'||prev_char||'%') and (curr_char = 'С' or curr_char = 'Ц') THEN
        SELECT right(uname, length(uname) - 1) INTO uname;
      ELSE
        IF curr_char = 'Ц' THEN SELECT 'С' INTO curr_char; END IF;
        IF prev_char <> curr_char THEN
          SELECT buffname || prev_char INTO buffname;
        END IF;
        SELECT right(uname, length(uname) - 1) INTO uname;
      END IF;
    ELSE
    SELECT right(uname, length(uname) - 1) INTO uname;
    END IF;

  END LOOP;
  RETURN   buffname;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION lastname_replace(uname TEXT)
RETURNS TEXT AS $$
DECLARE buffname text = '';
BEGIN
/*called after init replace*/
IF right(uname, 5) in ('ІАНКА') THEN
  RETURN  left_suffix(uname, 5)||'@';
ELSIF right(uname, 4) in ('ІНКА') THEN
  RETURN  left_suffix(uname, 4)||'@';
ELSIF right(uname, 7) in ('ІАВСКІЙ') THEN
  RETURN left_suffix(uname, 7)||'*';
ELSIF right(uname, 6) in ('АВСКІЙ', 'ІВСКІЙ', 'ОВСКІЙ') THEN
  RETURN left_suffix(uname, 6)||'*';
ELSIF right(uname, 7) in ('АВСКАІА', 'ІВСКАІА', 'ОВСКАІА') THEN
  RETURN left_suffix(uname, 7)||'#';
ELSIF right(uname, 5) in ('АВСКА', 'ІВСКА') THEN
  RETURN left_suffix(uname, 5)||'#';
ELSIF right(uname, 5) in ('СКАІА', 'ЦКАІА') THEN
  RETURN left_suffix(uname, 5)||'^';
ELSIF right(uname, 3) in ('СКА', 'ЦКА') THEN
  RETURN left_suffix(uname, 3)||'^';
ELSIF right(uname, 3) in ('ІВА') THEN
  RETURN left_suffix(uname, 3)||'9';
ELSIF right(uname, 5) in ('АВАІА') THEN
  RETURN left_suffix(uname, 5)||'9';
ELSIF right(uname, 3) in ('АВА') THEN
  RETURN left_suffix(uname, 3)||'9';
ELSIF right(uname, 4) in ('ІАІВ') THEN
  RETURN left_suffix(uname, 4)||'8';
ELSIF right(uname, 3) in ('ІОВ') THEN
  RETURN left_suffix(uname, 3)||'8';
ELSIF right(uname, 2) in ('ОВ') THEN
  RETURN left_suffix(uname, 2)||'8';
ELSIF right(uname, 2) in ('ІВ') THEN
  RETURN left_suffix(uname, 2)||'8';
ELSIF right(uname, 2) in ('АВ') THEN
  RETURN left_suffix(uname, 2)||'8';
ELSIF right(uname, 3) in ('ІНА') THEN
  RETURN left_suffix(uname, 3)||'7';
ELSIF right(uname, 2) in ('ІН') THEN
  RETURN left_suffix(uname, 2)||'6';
ELSIF right(uname, 3) in ('ІУК') THEN
  RETURN left_suffix(uname, 3)||'5';
ELSIF right(uname, 2) in ('УК') THEN
  RETURN left_suffix(uname, 2)||'5';
ELSIF right(uname, 3) in ('АІА') THEN
  RETURN left_suffix(uname, 3)||'4';
ELSIF right(uname, 2) in ('ІЙ') THEN
  RETURN left_suffix(uname, 2)||'3';
ELSIF right(uname, 2) in ('ІХ') THEN
  RETURN left_suffix(uname, 2)||'2';
ELSIF right(uname, 2) in ('ІК') THEN
  RETURN left_suffix(uname, 2)||'1';
ELSIF right(uname, 2) in ('КА') THEN
  RETURN left_suffix(uname, 2)||'0';
ELSE
  RETURN uname;
END IF;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION MetaPhoneUaRuLastName2(uname TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN consonant_replace(lastname_replace(known_char(vowel_replace(upper(uname)))));
END;
$$
LANGUAGE plpgsql
IMMUTABLE;
