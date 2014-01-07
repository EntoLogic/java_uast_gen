
{-# LANGUAGE MultiParamTypeClasses
           , FunctionalDependencies
           , FlexibleInstances
           , FlexibleContexts
           , CPP
           #-}

module Entologic.Convert where

import qualified Data.Text as T
import Data.Text (Text(..))

import qualified Language.Java.Syntax as J

import Entologic.Ast

class Convertable a b where
    convert :: a -> b

instance (Functor f, Convertable a b) => Convertable (f a) (f b) where
    convert = fmap convert

instance Convertable J.CompilationUnit Program where
    convert (J.CompilationUnit pkg imps typds) =
        CompilationUnit (convert pkg) (convert imps) (convert typds)

instance Convertable a b => Convertable a (AN b) where
    convert a = (Node $ convert a, Area Nothing Nothing)

instance Convertable J.PackageDecl [Text'] where
    convert (J.PackageDecl n) = convert n

instance Convertable J.Ident a => Convertable J.Name [a] where
    convert (J.Name idents) = convert idents

instance Convertable J.Ident Text where
    convert (J.Ident s) = T.pack s

instance Convertable String Text where
    convert = T.pack

instance Convertable J.ImportDecl Import where
    convert (J.ImportDecl True name True) = ImportStaticAll $ convert name
    convert (J.ImportDecl False name True) = ImportAll $ convert name
    convert (J.ImportDecl True name False) = ImportStatic $ convert name
    convert (J.ImportDecl False name False) = Import $ convert name

instance Convertable J.TypeDecl TypeDeclaration where
    convert (J.ClassTypeDecl c) = convert c
    convert (J.InterfaceTypeDecl i) = convert i

($>) :: Convertable a b => (b -> c) -> a -> c
func $> val = func $ convert val

instance Convertable J.ClassDecl TypeDeclaration where
    convert (J.ClassDecl mods name gParams sClass interfs body) =
        TDCls $ Class $> mods $> name $> gParams $> sClass $> interfs $> body

#define CV(thing) convert J.thing = thing
instance Convertable J.Modifier Modifier where
    CV(Public)
    CV(Private)
    CV(Protected)
    CV(Abstract)
    CV(Final)
    CV(Static)
    CV(StrictFP)
    CV(Transient)
    CV(Volatile)
    CV(Native)
    convert J.Synchronised = Synchronized

instance Convertable J.TypeParam GenericParamDecl where
    convert = const GenericParamDecl

instance Convertable J.RefType Type where
    convert (ClassRefType 