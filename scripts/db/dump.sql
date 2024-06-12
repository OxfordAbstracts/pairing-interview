create table if not exists users (
    id uuid primary key DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    first_name varchar(255),
    last_name varchar(255),
    email varchar(255),
    password varchar(255)
);

create table if not exists abstracts (
    id uuid primary key DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    title varchar(255),
    category varchar(255),
    body text,
    user_id uuid references users(id)
);

create table if not exists authors (
    id uuid primary key DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_id uuid references users(id),
    abstract_id uuid references abstracts(id),
    institution varchar(255)
);
