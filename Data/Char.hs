{-# OPTIONS_GHC -fno-implicit-prelude #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Char
-- Copyright   :  (c) The University of Glasgow 2001
-- License     :  BSD-style (see the file libraries/base/LICENSE)
-- 
-- Maintainer  :  libraries@haskell.org
-- Stability   :  stable
-- Portability :  portable
--
-- The Char type and associated operations.
--
-----------------------------------------------------------------------------

module Data.Char 
    (
      Char

    , String

    -- * Character classification
    -- | Unicode characters are divided into letters, numbers, marks,
    -- punctuation, symbols, separators (including spaces) and others
    -- (including control characters).
    , isAscii, isLatin1, isControl, isSpace
    , isLower, isUpper,  isAlpha,   isAlphaNum, isPrint
    , isDigit, isOctDigit, isHexDigit
    , isAsciiUpper, isAsciiLower
    , isLetter, isMark, isNumber, isPunctuation, isSymbol, isSeparator

    , GeneralCategory(..), generalCategory

    -- * Case conversion
    , toUpper, toLower, toTitle  -- :: Char -> Char

    -- * Single digit characters
    , digitToInt        -- :: Char -> Int
    , intToDigit        -- :: Int  -> Char

    -- * Numeric representations
    , ord               -- :: Char -> Int
    , chr               -- :: Int  -> Char

    -- * String representations
    , showLitChar       -- :: Char -> ShowS
    , lexLitChar	-- :: ReadS String
    , readLitChar       -- :: ReadS Char 

     -- Implementation checked wrt. Haskell 98 lib report, 1/99.
    ) where

#ifdef __GLASGOW_HASKELL__
import GHC.Base
import GHC.Real (fromIntegral)
import GHC.Show
import GHC.Read (Read, readLitChar, lexLitChar)
import GHC.Unicode
import GHC.Num
import GHC.Enum
#endif

#ifdef __HUGS__
import Hugs.Char
#endif

#ifdef __NHC__
import Prelude
import Prelude(Char,String)
import Char
import NHC.FFI (CInt)
foreign import ccall unsafe "WCsubst.h u_gencat" wgencat :: CInt -> Int
#endif

-- | Convert a single digit 'Char' to the corresponding 'Int'.  
-- This function fails unless its argument satisfies 'isHexDigit',
-- but recognises both upper and lower-case hexadecimal digits
-- (i.e. @\'0\'@..@\'9\'@, @\'a\'@..@\'f\'@, @\'A\'@..@\'F\'@).
digitToInt :: Char -> Int
digitToInt c
 | isDigit c		=  ord c - ord '0'
 | c >= 'a' && c <= 'f' =  ord c - ord 'a' + 10
 | c >= 'A' && c <= 'F' =  ord c - ord 'A' + 10
 | otherwise	        =  error ("Char.digitToInt: not a digit " ++ show c) -- sigh

#ifndef __GLASGOW_HASKELL__
isAsciiUpper, isAsciiLower :: Char -> Bool
isAsciiLower c          =  c >= 'a' && c <= 'z'
isAsciiUpper c          =  c >= 'A' && c <= 'Z'
#endif

-- | Unicode General Categories (column 2 of the UnicodeData table)
-- in the order they are listed in the Unicode standard.

data GeneralCategory
        = UppercaseLetter       -- ^ Lu: Letter, Uppercase
        | LowercaseLetter       -- ^ Ll: Letter, Lowercase
        | TitlecaseLetter       -- ^ Lt: Letter, Titlecase
        | ModifierLetter        -- ^ Lm: Letter, Modifier
        | OtherLetter           -- ^ Lo: Letter, Other
        | NonSpacingMark        -- ^ Mn: Mark, Non-Spacing
        | SpacingCombiningMark  -- ^ Mc: Mark, Spacing Combining
        | EnclosingMark         -- ^ Me: Mark, Enclosing
        | DecimalNumber         -- ^ Nd: Number, Decimal
        | LetterNumber          -- ^ Nl: Number, Letter
        | OtherNumber           -- ^ No: Number, Other
        | ConnectorPunctuation  -- ^ Pc: Punctuation, Connector
        | DashPunctuation       -- ^ Pd: Punctuation, Dash
        | OpenPunctuation       -- ^ Ps: Punctuation, Open
        | ClosePunctuation      -- ^ Pe: Punctuation, Close
        | InitialQuote          -- ^ Pi: Punctuation, Initial quote
        | FinalQuote            -- ^ Pf: Punctuation, Final quote
        | OtherPunctuation      -- ^ Po: Punctuation, Other
        | MathSymbol            -- ^ Sm: Symbol, Math
        | CurrencySymbol        -- ^ Sc: Symbol, Currency
        | ModifierSymbol        -- ^ Sk: Symbol, Modifier
        | OtherSymbol           -- ^ So: Symbol, Other
        | Space                 -- ^ Zs: Separator, Space
        | LineSeparator         -- ^ Zl: Separator, Line
        | ParagraphSeparator    -- ^ Zp: Separator, Paragraph
        | Control               -- ^ Cc: Other, Control
        | Format                -- ^ Cf: Other, Format
        | Surrogate             -- ^ Cs: Other, Surrogate
        | PrivateUse            -- ^ Co: Other, Private Use
        | NotAssigned           -- ^ Cn: Other, Not Assigned
        deriving (Eq, Ord, Enum, Read, Show, Bounded)

-- | Retrieves the general Unicode category of the character.
generalCategory :: Char -> GeneralCategory
#if defined(__GLASGOW_HASKELL__) || defined(__NHC__)
generalCategory c = toEnum (wgencat (fromIntegral (ord c)))
#endif
#ifdef __HUGS__
generalCategory c = toEnum (primUniGenCat c)
#endif

-- derived character classifiers

isLetter :: Char -> Bool
isLetter c = case generalCategory c of
        UppercaseLetter         -> True
        LowercaseLetter         -> True
        TitlecaseLetter         -> True
        ModifierLetter          -> True
        OtherLetter             -> True
        _                       -> False

isMark :: Char -> Bool
isMark c = case generalCategory c of
        NonSpacingMark          -> True
        SpacingCombiningMark    -> True
        EnclosingMark           -> True
        _                       -> False

isNumber :: Char -> Bool
isNumber c = case generalCategory c of
        DecimalNumber           -> True
        LetterNumber            -> True
        OtherNumber             -> True
        _                       -> False

isPunctuation :: Char -> Bool
isPunctuation c = case generalCategory c of
        ConnectorPunctuation    -> True
        DashPunctuation         -> True
        OpenPunctuation         -> True
        ClosePunctuation        -> True
        InitialQuote            -> True
        FinalQuote              -> True
        OtherPunctuation        -> True
        _                       -> False

isSymbol :: Char -> Bool
isSymbol c = case generalCategory c of
        MathSymbol              -> True
        CurrencySymbol          -> True
        ModifierSymbol          -> True
        OtherSymbol             -> True
        _                       -> False

isSeparator :: Char -> Bool
isSeparator c = case generalCategory c of
        Space                   -> True
        LineSeparator           -> True
        ParagraphSeparator      -> True
        _                       -> False

#ifdef __NHC__
-- dummy implementation
toTitle :: Char -> Char
toTitle = toUpper
#endif
