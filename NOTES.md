# To Do

- [x] Fix images in old posts. Image link format is different. Presumably linking to another post within the blog will also be different, so check that out and fix it as well!
- [ ] Add RSS feed
- [x] Add some light theming. Maybe sans serif font, dark background? Crib from Catppuccin colors? Or use IA Writer Quatro?

# Notes to myself

## Cabal notes

Most folks seem to be using Stack for everything, but I'm just using Cabal since that's what seems to be the default with GHCup. When I edit site.hs, it seems like I have to run `cabal install site --overwrite-policy=always` to get the changes to take effect if I want to be able to use `site build` or `site watch`, which seems like probably not what I'm supposed to be doing.

Instead, if I do:

    cabal build
    cabal run site rebuild
    cabal run site watch

The `cabal run` seems to work the same as the `stack exec` I see in the tutorials, and doesn't require the install with overwrite flag. I think I'll stick to the `cabal run` approach since that mirrors the tutorials more, but clearly I should learn more about what the heck cabal and stack are doing here!

## Migrating from Jekyll

### Fixing links

Remove all the special kramdown open links in new window stuff that Hakyll doesn't support (and that I don't really want anymore anywas):

    find . -type f -exec sed -i 's/{:target="_blank"}//g' {} \;

Fix the old Jekyll-style image links by swapping assets to images and stripping all the extra {{}} stuff:

    find . -type f -exec sed -i 's@ {{ "/assets@/images@g' {} \;
    find . -type f -exec sed -i 's@" | absolute_url }} @@g' {} \;

Fix internal links:

    find . -type f -exec sed -i 's/{% post_url //g' {} \;
    find . -type f -exec sed -i 's/ %}/.html/g' {} \;

Any external links to individual posts on my blog will be broken by the change to hakyll, but I think that's okay.
