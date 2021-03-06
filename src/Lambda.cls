VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Lambda"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
'
' Lambda
' ======
'
' Copywrite (C) 2014 Philip Wales
' Original idea from Mathieu Guindon.
' This file (Lambda.cls) is distributed under the GPL-3.0 license
' Obtain a copy of the GPL-3.0 license <http://opensource.org/licenses/GPL-3.0>
'
' Create lambda expressions from strings using
' either C# notation
'
'       "(x, y, z) => x * y + z"
'
' Or Scala-ish short hand
'
'      "( _ * _ ) + _"
'
' both produce the same result
'
' RESTRICTIONS
' ------------
'
'   Lambdas currently must be completely independent of external definitions.
 ' One cannot reference external varaibles or functions from a lambda.  This
' is because Lambda simple translates the strings to a proper function defintion
' that are written to an external blank module.  That module is reference by the
' client code but not visa versa.
'
' _eg_ both of these are invalid:
'
'     Public Function Intersect(ByVal other As SortedSet) As SortedSet
'        Set Intersect = Filter(Lambda.FromString("(x) => other.Exists(x)")
'     End Function
'
' `Other` is not decalared in the scope of the created lambda function.
'
'     Public Function Foo() As Integer
'         Foo = 12
'     End Function
'     Public Sub Bar()
'         Debug.Print List.Create(1,2,3).Map(Lambda.FromShort("_ + Foo()")).Show
'     End Sub
'
' `Foo` is not declared in the scope of the lambda.
'
'  Currently, the external module is located inside of the VBEX project.
' So it should be able to reference VBEX methods.  Ergo, this is valid.
'
'    Private Function BaseNames(ByVal filepaths As List) As List
'        Set BaseNames = filepaths.Map(Lambda.FromProper("(f) => path.BaseName(f)"))
'    End Function
'
'
' TODO:
' -----
'
'  - pass local variables to the lambda.
'
Option Explicit
Implements Showable
Implements Applicable
'
' Constants
' ---------
'
Private Const CANNOT_FIND_MACRO As Integer = 1004
Private Const INVALID_LAMBDA_EXPRESSION As Integer = 666 ' TODO:
Private Const SHORT_HAND_CHAR As String = "_" ' TODO: it's acutal name
'
' Private Members
' ---------------
'
Private pId As String ' name of the lamda in LambdaTable
Private pExpression As String ' Only for the `Show` method
'
' Class
' -----
Private Sub Class_Terminate()
    
    LambdaTable.RemoveLambda pId
    
End Sub
'
' Constructors
' ------------
'
''
' Create an Lambda Function
Public Function Make(ByRef args() As String, ByVal expr As String) As Lambda
    
    Dim result As New Lambda
    result.SendToLambdaTable args, expr
    Set Make = result
    
End Function
'
' "(args) => expr"
' Public Function func(args) As Variant
' cast.Assign func, expr
' End Function
Public Function FromProper(ByVal proper As String) As Lambda

    Dim splitExpr() As String
    splitExpr = Split(proper, ") => ")
    
    Dim params As String
    params = Mid$(splitExpr(0), 2) ' skip "("
    
    Dim expr As String
    expr = splitExpr(1)
    
    Dim args() As String
    args = Split(Replace$(params, " ", ""), ",")
    
    Set FromProper = Make(args, expr)
    
End Function
Public Function FromShort(ByVal shorthand As String) As Lambda

    Const ASCaCODE As Integer = 97 ' Asc("a")
    
    Dim expr As String
    expr = shorthand
    
    Dim argsize As Integer
    argsize = UBound(Split(expr, SHORT_HAND_CHAR)) - 1
    
    Dim args() As String
    ReDim args(0 To argsize)
    
    Dim i As Integer
    For i = 0 To argsize
    
        Dim paramChar As String
        paramChar = Chr(ASCaCODE + i)
        
        expr = Replace(expr, SHORT_HAND_CHAR, paramChar, Count:=1)
        
        args(i) = paramChar
        
    Next i
    
    Set FromShort = Make(args, expr)
    
End Function
'
' Friend Methods
' --------------
'
Friend Sub SendToLambdaTable(ByRef args() As String, ByVal expr As String)
    
    pExpression = expr
    pId = LambdaTable.AddLambda(args, expr)
    
End Sub
'
' Applicable
' -----------
'
' ### Meaningful
'
Public Function ApplyOnArray(ByRef args() As Variant) As Variant
    
    Assign ApplyOnArray, defApply.ApplicationRunOnArray(pId, args)
    
End Function
'
' ### Embeded
'
'! default member
Public Function Apply(ParamArray args()) As Variant
Attribute Apply.VB_UserMemId = 0

    Assign Apply, ApplyOnArray(CArray(args))

End Function
Private Function Applicable_Apply(ParamArray args()) As Variant

    Assign Applicable_Apply, ApplyOnArray(CArray(args))
    
End Function
Private Function Applicable_ApplyOnArray(ByRef args() As Variant) As Variant
    
    Assign Applicable_ApplyOnArray, ApplyOnArray(args)
    
End Function
Public Function Compose(ByVal f As Applicable) As Applicable

    Set Compose = defApply.Compose(Me, f)

End Function
Private Function Applicable_Compose(ByVal f As Applicable) As Applicable

    Set Applicable_Compose = Compose(f)

End Function
Public Function AndThen(ByVal g As Applicable) As Applicable

    Set AndThen = defApply.AndThen(Me, g)

End Function
Private Function Applicable_AndThen(ByVal g As Applicable) As Applicable

    Set Applicable_AndThen = AndThen(g)

End Function
Public Function Partial(ParamArray args() As Variant) As Applicable

    Set Partial = AsPartial(CArray(args))

End Function
Private Function Applicable_Partial(ParamArray args() As Variant) As Applicable

    Set Applicable_Partial = AsPartial(CArray(args))

End Function
Public Function AsPartial(ByRef args() As Variant) As Applicable

    Set AsPartial = defApply.AsPartial(Me, args)

End Function
Private Function Applicable_AsPartial(ByRef args() As Variant) As Applicable

    Set Applicable_AsPartial = AsPartial(args)

End Function
Public Function delay(ParamArray args() As Variant) As Delayed

    Set delay = AsDelay(CArray(args))

End Function
Private Function Applicable_Delay(ParamArray args() As Variant) As Delayed

    Set Applicable_Delay = AsDelay(CArray(args))

End Function
Public Function AsDelay(ByRef args() As Variant) As Delayed

    Set AsDelay = defApply.AsDelay(Me, args)

End Function
Private Function Applicable_AsDelay(ByRef args() As Variant) As Delayed

    Set Applicable_AsDelay = AsDelay(args)

End Function

'
' Showable
' ---------
'
Public Function Show() As String

    Show = defShow.ParamShowableObject(Me, pId, pExpression)

End Function
Private Function Showable_Show() As String

    Showable_Show = Show
    
End Function
