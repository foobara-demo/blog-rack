module FoobaraDemo
  module BlogRack
    # :nocov:
    PERMISSIONS = {
      auth_map: {
        blog_auth_user: FoobaraDemo::BlogAuth::User,
        blog_user: FoobaraDemo::BlogAuth::FindBlogUserForAuthUser
      },
      requires_allowed_rule: true,
      allowed_rules: {
        is_article_author: -> { blog_user == article.author },
        is_author: -> { blog_user == author },
        is_published: -> { article.published? }
      },
      allow: {
        FoobaraDemo::Blog::StartNewArticle => :is_author,
        FoobaraDemo::Blog::DeleteArticle => :is_article_author,
        FoobaraDemo::Blog::EditArticle => :is_article_author,
        FoobaraDemo::Blog::PublishArticle => :is_article_author,
        FoobaraDemo::Blog::PublishArticleChanges => :is_article_author,
        FoobaraDemo::Blog::UnpublishArticle => :is_article_author,
        FoobaraDemo::Blog::FindArticle => [:is_article_author, :is_published],
        FoobaraDemo::Blog::FindArticles => :is_author,
        FoobaraDemo::Blog::FindArticleSummaries => :is_author,

        Foobara::Auth::DeleteApiKey => -> { authenticated_user.api_keys.include?(token) }
      }
    }.freeze
    # :nocov:
  end
end
