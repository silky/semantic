{-# LANGUAGE DataKinds #-}
module Language.Markdown where

import CMark
import Data.Record
import Data.Text
import Info
import Parser
import Prologue
import Range
import Source
import SourceSpan
import Syntax

cmarkParser :: Parser (Syntax Text) (Record '[Range, Category])
cmarkParser SourceBlob{..} = pure . toTerm (totalRange source) $ commonmarkToNode [ optSourcePos, optSafe ] (toText source)
  where toTerm :: Range -> Node -> Cofree (Syntax Text) (Record '[Range, Category])
        toTerm within (Node position t children) = let range = maybe within (sourceSpanToRange source . toSpan) position in cofree $ (range .: toCategory t .: RNil) :< case t of
          -- Leaves
          CODE text -> Leaf text
          TEXT text -> Leaf text
          CODE_BLOCK _ text -> Leaf text
          -- Branches
          _ -> Indexed (toTerm range <$> children)

        toCategory :: NodeType -> Category
        toCategory (TEXT _) = Other "text"
        toCategory (CODE _) = Other "code"
        toCategory (HTML_BLOCK _) = Other "html"
        toCategory (HTML_INLINE _) = Other "html"
        toCategory (HEADING _) = Other "heading"
        toCategory (LIST (ListAttributes{..})) = Other $ case listType of
          BULLET_LIST -> "unordered list"
          ORDERED_LIST -> "ordered list"
        toCategory (LINK{}) = Other "link"
        toCategory (IMAGE{}) = Other "image"
        toCategory t = Other (show t)
        toSpan PosInfo{..} = SourceSpan "" (SourcePos (pred startLine) (pred startColumn)) (SourcePos (pred endLine) endColumn)