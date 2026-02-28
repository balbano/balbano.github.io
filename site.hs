--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Data.List   (stripPrefix)
import           Data.Maybe  (fromMaybe)
import           Hakyll


--------------------------------------------------------------------------------

-- Custom configuration

config :: Configuration
config = defaultConfiguration
  { destinationDirectory = "docs" -- for GitHub Pages
  }

-- Contexts

postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

feedCtx :: Context String
feedCtx = postCtx `mappend` bodyField "description"

-- Feed configuration

feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle       = "Brendan's Blog"
    , feedDescription = "I mostly write about tabletop games, art, baking and my feelings."
    , feedAuthorName  = "Brendan Albano"
    , feedAuthorEmail = "brendan@brendanalbano.com"
    , feedRoot        = "https://www.brendanalbano.com"
    }

-- Auxilery compilers

-- externalizeUrls and unUnexternalizeUrls from https://github.com/Keruspe/blog/tree/master
-- For making rss/atom feed links render correctly in the snapshot.
-- I had to appand a "/" to root to make the links in the feed work.

externalizeUrls :: String -> Item String -> Compiler (Item String)
externalizeUrls root item = return $ withUrls ext <$> item
  where
    ext x = if isExternal x then x else root ++ "/" ++ x

unExternalizeUrls :: String -> Item String -> Compiler (Item String)
unExternalizeUrls root item = return $ withUrls unExt <$> item
  where
    unExt x = fromMaybe x $ stripPrefix (root ++ "/") x

main :: IO ()
main = hakyllWith config $ do
    match "CNAME" $ do
        route   idRoute
        compile copyFileCompiler

    match "images/**" $ do -- ** to allow organizing in subfolders
        route   idRoute
        compile copyFileCompiler

    match "fonts/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.markdown", "blogroll.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= (externalizeUrls     $ feedRoot feedConfiguration)
            >>= saveSnapshot         "content"
            >>= (unExternalizeUrls   $ feedRoot feedConfiguration)
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- fmap (take 10) . recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler

    -- Render RSS feed
    create ["feed.xml"] $ do
        route idRoute
        compile $ do
            loadAllSnapshots "posts/*" "content"
                >>= recentFirst
                >>= renderAtom feedConfiguration feedCtx
