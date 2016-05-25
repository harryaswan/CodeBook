select p1.p_text from posts p1
inner join friends f1
on p1.user_id = f1.b_id
inner join users b1
on b1.id = f1.b_id
inner join users a1
on a1.id = f1.a_id
where a1.f_name in (select f_name from users u1 where u1.id = f1.a_id)
union
select p1.p_text from posts p1
inner join friends f1
on p1.user_id = f1.a_id
inner join users a1
on a1.id = f1.b_id
inner join users b1
on b1.id = f1.b_id
where b1.f_name in (select f_name from users u1 where u1.id = f1.b_id);




DO $do$
DECLARE
test INTEGER;
BEGIN
test = SELECT id FROM conversations WHERE a_id=11 AND b_id=9;
IF NOT FOUND THEN
INSERT INTO conversations (a_id, b_id) VALUES (11, 9);
END IF;
END
$do$;

**example that works**
CREATE OR REPLACE FUNCTION get(_param_a_id integer, _param_b_id integer)
  RETURNS integer AS
$func$
BEGIN

RETURN (SELECT id FROM conversations WHERE a_id = _param_a_id AND b_id = _param_b_id);

END
$func$ LANGUAGE plpgsql;

**

CREATE OR REPLACE FUNCTION yay(_post_id integer, _user_id integer)
    RETURNS integer AS
$$
BEGIN

    DELETE FROM post_yays WHERE post_id = _post_id AND user_id = _user_id;
    IF NOT FOUND THEN
        INSERT INTO post_yays (post_id, user_id) VALUES (_post_id, _user_id);
        RETURN 1;
    END IF;

    RETURN 0;

END
$$ LANGUAGE plpgsql;


DO $do$ BEGIN DELETE FROM post_yays WHERE post_id = #{@id} AND user_id = #{id}; IF NOT FOUND THEN INSERT INTO post_yays (post_id, user_id) VALUES (#{@id}, #{id}); END IF; END $do$



TABLE(id integer, a_id integer, b_id integer)
SETOF conversations

CREATE OR REPLACE FUNCTION create_convo(_a_id integer, _b_id integer)
    RETURNS SETOF conversations AS
$$
BEGIN

    IF NOT EXISTS(SELECT true FROM conversations c WHERE (c.a_id = _a_id OR c.a_id = _b_id) AND (c.b_id = _a_id OR c.b_id = _b_id)) THEN
        INSERT INTO conversations (a_id, b_id) VALUES (_a_id, _b_id);
    END IF;
    RETURN QUERY SELECT * FROM conversations c WHERE (c.a_id = _a_id OR c.a_id = _b_id) AND (c.b_id = _a_id OR c.b_id = _b_id);

END
$$ LANGUAGE plpgsql;
