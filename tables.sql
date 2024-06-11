create table users (
    id uuid primary key,
    first_name varchar(255),
    last_name varchar(255),
    email varchar(255),
    password varchar(255)
);

create table abstracts (
    id uuid primary key,
    title varchar(255),
    category varchar(255),
    body text,
    user_id uuid references users(id)
);

create table authors (
    id uuid primary key,
    user_id uuid references users(id),
    abstract_id uuid references abstracts(id)
    institution varchar(255)
);
