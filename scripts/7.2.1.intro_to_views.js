const nano = require('nano');

async function main() {
  try {
    const couch = await nano('http://admin:password@couchdb.docker.com:5984');

    try {
      await couch.db.destroy('blog_posts');
    } catch (e) {
      if (e.error !== 'not_found') {
        throw e;
      }
    }

    await couch.db.create('blog_posts');

    const blogPosts = couch.use('blog_posts');

    const designDoc = {
      language: "javascript",
      views: {
        'tags_view': {
          map: function (doc) {
            if (doc.type === 'post' && doc.tags.length > 0) {
              doc.tags.forEach(function (tag) {
                emit(tag, null);
              });
            }
          },
        },
        'sorted_by_date_view': {
          map: function (doc) {
            if (doc.type === 'post' && doc.date && doc.title) {
              emit(doc.date, doc.title);
            }
          },
        },
        'comments_view': {
          map: function (doc) {
            if (doc.type === 'comment') {
              emit(doc.example_key, { author: doc.author, body: doc.body });
            }
          },
          reduce: function (keys, values, rereduce) {
            if (rereduce) {
              return sum(values);
            } else {
              return values.length;
            }
          },
        },
      },
    }

    await blogPosts.insert(designDoc, '_design/blog_posts');

    const blogPostDocs = [
      {
        "_id":"biking",
        "type":"post",
        "title":"Biking",
        "body":"My biggest hobby is mountainbiking. The other day...",
        "tags":["cool", "freak", "plankton"],
        "date":[2009, 2, 17, 21, 13, 39],
      },
      {
        "_id":"bought-a-cat",
        "type":"post",
        "title":"Bought a Cat",
        "body":"I went to the the pet store earlier and brought home a little kitty...",
        "tags":["plankton"],
        "date":[2009, 1, 30, 18, 4, 11],
      },
      {
        "_id":"hello-world",
        "type":"post",
        "title":"Hello World",
        "body":"Well hello and welcome to my new blog...",
        "date":[2009, 1, 15, 15, 52, 20],
      },
    ];

    await blogPosts.bulk({ docs: blogPostDocs });

    let body;

    body = await blogPosts.view('blog_posts', 'sorted_by_date_view',
      {
        startkey: [2009, 1, 1, 0, 0, 0],
        endkey: [2009, 2, 1, 0, 0, 0],
      });

    console.info('sorted_by_date startkey endkey view result:');
    console.info(body.rows);

    body = await blogPosts.view('blog_posts', 'sorted_by_date_view',
      {
        keys: [
          [2009, 1, 15, 15, 52, 20],
          [2009, 2, 17, 21, 13, 39],
        ],
      });

    console.info('sorted_by_date specific keys view result:');
    console.info(body.rows);

    body = await blogPosts.view('blog_posts', 'tags_view');

    console.info('tags view result:');
    console.info(body.rows);

    body = await blogPosts.view('blog_posts', 'tags_view',
      { descending: true });

    console.info('reversed tags view result:');
    console.info(body.rows);

    const commentsDocs = [
      {
        _id: "comment0",
        example_key: ["a","b","c"],
        type: "comment",
        author: 'Bob',
        body: 'A comment about something',
      },
      {
        _id: "comment1",
        example_key: ["a","b","e"],
        type: "comment",
        author: 'Karen',
        body: 'A comment about something',
      },
      {
        _id: "comment2",
        example_key: ["a","c","m"],
        type: "comment",
        author: 'Elvis',
        body: 'A comment about something',
      },
      {
        _id: "comment3",
        example_key: ["b","a","c"],
        type: "comment",
        author: 'Denise',
        body: 'A comment about something',
      },
      {
        _id: "comment4",
        example_key: ["b","a","g"],
        type: "comment",
        author: 'Janice',
        body: 'A comment about something',
      },
    ];

    await blogPosts.bulk({ docs: commentsDocs });

    body = await blogPosts.view('blog_posts', 'comments_view',
      { group_level: 0 });
    console.info('comments view result:');
    console.info(body.rows);

    body = await blogPosts.view('blog_posts', 'comments_view',
      { group_level: 1 });
    console.info('group_level 1 comments view result:');
    console.info(body.rows);

    body = await blogPosts.view('blog_posts', 'comments_view',
      { group_level: 2 });
    console.info('group_level 2 comments view result:');
    console.info(body.rows);

    body = await blogPosts.view('blog_posts', 'comments_view',
      { group_level: 3 });
    console.info('group_level 3 comments view result:');
    console.info(body.rows);

  } catch (error) {
    console.error(error);
  }
}

main();
