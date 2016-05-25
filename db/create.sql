DROP TABLE messages;
DROP TABLE conversations;
DROP TABLE friends;
DROP TABLE post_nays;
DROP TABLE post_yays;
DROP TABLE comments;
DROP TABLE posts;
DROP TABLE users;


CREATE TABLE users (
        id serial8 primary key,
        username varchar(255),
        password varchar(255),
        f_name varchar(255),
        l_name varchar(255),
        tagline varchar(255),
        img_url text,
        UNIQUE (username)
);

CREATE TABLE posts (
        id serial8 primary key,
        user_id int8 references users(id) ON DELETE CASCADE,
        posted timestamp default NOW(),
        p_text text
);

CREATE TABLE comments (
        id serial8 primary key,
        user_id int8 references users(id) ON DELETE CASCADE,
        post_id int8 references posts(id) ON DELETE CASCADE,
        commented timestamp default NOW(),
        c_text text
);

CREATE TABLE post_yays (
        user_id int8 references users(id) ON DELETE CASCADE,
        post_id int8 references posts(id) ON DELETE CASCADE,
        PRIMARY KEY (user_id, post_id)
);

CREATE TABLE post_nays (
        user_id int8 references users(id) ON DELETE CASCADE,
        post_id int8 references posts(id) ON DELETE CASCADE,
        PRIMARY KEY (user_id, post_id)
);

CREATE TABLE friends (
        a_id int8 references users(id) ON DELETE CASCADE,
        b_id int8 references users(id) ON DELETE CASCADE,
        confirmed boolean default false,
        PRIMARY KEY (a_id, b_id)
);

CREATE TABLE conversations (
        id serial8 primary key,
        a_id int8 references users(id) ON DELETE CASCADE,
        b_id int8 references users(id) ON DELETE CASCADE
);

CREATE TABLE messages (
        id serial8 primary key,
        s_id int8 references users(id) ON DELETE CASCADE,
        c_id int8 references conversations(id) ON DELETE CASCADE,
        msg text,
        read boolean default false,
        sent timestamp default NOW()
);


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

CREATE OR REPLACE FUNCTION nay(_post_id integer, _user_id integer)
    RETURNS integer AS
$$
BEGIN

    DELETE FROM post_nays WHERE post_id = _post_id AND user_id = _user_id;
    IF NOT FOUND THEN
        INSERT INTO post_nays (post_id, user_id) VALUES (_post_id, _user_id);
        RETURN 1;
    END IF;

    RETURN 0;

END
$$ LANGUAGE plpgsql;


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


CREATE OR REPLACE FUNCTION add_friend(_a_id integer, _b_id integer)
    RETURNS integer AS
$$
BEGIN

    IF NOT EXISTS(SELECT true FROM friends WHERE (a_id = _a_id OR a_id = _b_id) AND (b_id = _a_id OR b_id = _b_id)) THEN
        INSERT INTO friends (a_id, b_id) VALUES (_a_id, _b_id);
        RETURN 1;
    END IF;
    RETURN 0;

END
$$ LANGUAGE plpgsql;
