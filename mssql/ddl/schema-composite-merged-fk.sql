-- static tables
USE ldbc;
CREATE TABLE Organisation (
    id bigint PRIMARY KEY,
    type varchar(12) NOT NULL,
    name nvarchar(256) NOT NULL,
    url varchar(256) NOT NULL,
    LocationPlaceId bigint NOT NULL
);

CREATE TABLE Place (
    id bigint PRIMARY KEY,
    name nvarchar(256) NOT NULL,
    url varchar(256) NOT NULL,
    type varchar(12) NOT NULL,
    PartOfPlaceId bigint -- null for continents
);

CREATE TABLE Tag (
    id bigint PRIMARY KEY,
    name nvarchar(256) NOT NULL,
    url varchar(256) NOT NULL,
    TypeTagClassId bigint NOT NULL
);

CREATE TABLE TagClass (
    id bigint PRIMARY KEY,
    name nvarchar(256) NOT NULL,
    url varchar(256) NOT NULL,
    SubclassOfTagClassId bigint -- null for the root TagClass (Thing)
);

-- static tables / separate table per individual subtype

CREATE TABLE Country (
    id bigint primary key,
    name nvarchar(256) not null,
    url varchar(256) not null,
    PartOfContinentId bigint
);

CREATE TABLE City (
    id bigint primary key,
    name nvarchar(256) not null,
    url varchar(256) not null,
    PartOfCountryId bigint
);

CREATE TABLE Company (
    id bigint primary key,
    name nvarchar(256) not null,
    url varchar(256) not null,
    LocationPlaceId bigint not null
);

CREATE TABLE University (
    id bigint primary key,
    name nvarchar(256) not null,
    url varchar(256) not null,
    LocationPlaceId bigint not null
);

-- dynamic tables

CREATE TABLE Comment (
    creationDate datetimeoffset NOT NULL,
    id bigint,
    locationIP varchar(40) NOT NULL,
    browserUsed varchar(40) NOT NULL,
    content ntext NOT NULL,
    length int NOT NULL,
    CreatorPersonId bigint NOT NULL,
    LocationCountryId bigint NOT NULL,
    ParentPostId bigint,
    ParentCommentId bigint
);

CREATE TABLE Forum (
    creationDate datetimeoffset NOT NULL,
    id bigint,
    title nvarchar(256) NOT NULL,
    ModeratorPersonId bigint -- can be null as its cardinality is 0..1
);

CREATE TABLE Post (
    creationDate datetimeoffset NOT NULL,
    id bigint,
    imageFile varchar(40),
    locationIP varchar(40) NOT NULL,
    browserUsed varchar(40) NOT NULL,
    language varchar(40),
    content ntext,
    length int NOT NULL,
    CreatorPersonId bigint NOT NULL,
    ContainerForumId bigint NOT NULL,
    LocationCountryId bigint NOT NULL
);

CREATE TABLE [dbo].[Person] (
    [creationDate] datetimeoffset      NOT NULL,
    [personId]     BIGINT        NOT NULL,
    [firstName]    nvarchar (MAX) NOT NULL,
    [lastName]     nvarchar (MAX) NOT NULL,
    [gender]       nvarchar (50) NOT NULL,
    [birthday]     DATETIME      NOT NULL,
    [locationIP]   nvarchar (50) NOT NULL,
    [browserUsed]  nvarchar (500) NOT NULL,
    [LocationCityId]    BIGINT NOT NULL,
    [language] varchar(640) NOT NULL,
    [email] varchar(MAX) NOT NULL
    CONSTRAINT PK_Person PRIMARY KEY NONCLUSTERED ([personId] ASC) WITH (DATA_COMPRESSION = PAGE),
       CONSTRAINT Graph_Unique_Key_Person UNIQUE CLUSTERED ($node_id) WITH (DATA_COMPRESSION = PAGE)
) AS NODE;

-- CREATE TABLE Person (
--     creationDate datetimeoffset NOT NULL,
--     id bigint,
--     firstName nvarchar(40) NOT NULL,
--     lastName nvarchar(40) NOT NULL,
--     gender varchar(40) NOT NULL,
--     birthday date NOT NULL,
--     locationIP varchar(40) NOT NULL,
--     browserUsed varchar(40) NOT NULL,
--     LocationCityId bigint NOT NULL,
--     speaks varchar(640) NOT NULL,
--     email varchar(MAX) NOT NULL
-- );

-- edges
CREATE TABLE Comment_hasTag_Tag (
    creationDate datetimeoffset NOT NULL,
    CommentId bigint NOT NULL,
    TagId bigint NOT NULL
);

CREATE TABLE Post_hasTag_Tag (
    creationDate datetimeoffset NOT NULL,
    PostId bigint NOT NULL,
    TagId bigint NOT NULL
);

CREATE TABLE Forum_hasMember_Person (
    creationDate datetimeoffset NOT NULL,
    ForumId bigint NOT NULL,
    PersonId bigint NOT NULL
);

CREATE TABLE Forum_hasTag_Tag (
    creationDate datetimeoffset NOT NULL,
    ForumId bigint NOT NULL,
    TagId bigint NOT NULL
);

CREATE TABLE Person_hasInterest_Tag (
    creationDate datetimeoffset NOT NULL,
    PersonId bigint NOT NULL,
    TagId bigint NOT NULL
);

CREATE TABLE Person_likes_Comment (
    creationDate datetimeoffset NOT NULL,
    PersonId bigint NOT NULL,
    CommentId bigint NOT NULL
);

CREATE TABLE Person_likes_Post (
    creationDate datetimeoffset NOT NULL,
    PersonId bigint NOT NULL,
    PostId bigint NOT NULL
);

CREATE TABLE Person_studyAt_University (
    creationDate datetimeoffset NOT NULL,
    PersonId bigint NOT NULL,
    UniversityId bigint NOT NULL,
    classYear int NOT NULL
);

CREATE TABLE Person_workAt_Company (
    creationDate datetimeoffset NOT NULL,
    PersonId bigint NOT NULL,
    CompanyId bigint NOT NULL,
    workFrom int NOT NULL
);

-- CREATE TABLE Person_knows_Person (
--     creationDate datetimeoffset NOT NULL,
--     Person1id bigint NOT NULL,
--     Person2id bigint NOT NULL
-- );

CREATE TABLE [dbo].[Person_knows_Person] (
       creationDate datetimeoffset NOT NULL,
       INDEX [GRAPH_UNIQUE_INDEX_Person_knows_Person] UNIQUE NONCLUSTERED ($edge_id) WITH (DATA_COMPRESSION = PAGE),
       INDEX [GRAPH_FromTo_INDEX_Person_knows_Person] CLUSTERED ($from_id, $to_id) WITH (DATA_COMPRESSION = PAGE)
       , INDEX [GRAPH_ToFrom_INDEX_Person_knows_Person] NONCLUSTERED ($to_id, $from_id) WITH (DATA_COMPRESSION = PAGE)
) AS EDGE;

ALTER INDEX [GRAPH_UNIQUE_INDEX_Person_knows_Person] ON [dbo].[Person_knows_Person] DISABLE;

-- materialized views

-- A recursive materialized view containing the root Post of each Message (for Posts, themselves, for Comments, traversing up the Message thread to the root Post of the tree)
CREATE TABLE Message (
    creationDate datetimeoffset not null,
    MessageId bigint,
    RootPostId bigint not null,
    RootPostLanguage varchar(40),
    content ntext,
    imageFile varchar(40),
    locationIP varchar(40) not null,
    browserUsed varchar(40) not null,
    length int not null,
    CreatorPersonId bigint not null,
    ContainerForumId bigint,
    LocationCountryId bigint not null,
    ParentMessageId bigint,
    ParentPostId bigint,
    ParentCommentId bigint,
    type varchar(7)
);

CREATE TABLE Person_likes_Message (
    creationDate datetimeoffset NOT NULL,
    PersonId bigint NOT NULL,
    MessageId bigint NOT NULL
);

CREATE TABLE Message_hasTag_Tag (
    creationDate datetimeoffset NOT NULL,
    MessageId bigint NOT NULL,
    TagId bigint NOT NULL
);

-- views

CREATE VIEW Comment_View AS
    SELECT creationDate, MessageId AS id, locationIP, browserUsed, content, length, CreatorPersonId, LocationCountryId, ParentPostId, ParentCommentId
    FROM Message
    WHERE ParentMessageId IS NOT NULL;

CREATE VIEW Post_View AS
    SELECT creationDate, MessageId AS id, imageFile, locationIP, browserUsed, RootPostLanguage, content, length, CreatorPersonId, ContainerForumId, LocationCountryId
    From Message
    WHERE ParentMessageId IS NULL;
