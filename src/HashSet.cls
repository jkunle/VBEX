VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "HashSet"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
'
' HashSet
' =======
'
Option Explicit

Implements Equatable
Implements Showable
Implements SetLike
Implements Buildable
'
' Public Members
' --------------
' None
'
' Private Memebers
' ----------------
'
Private pDict As Scripting.Dictionary
'
' Private Methods
' ---------------
'
''
' Destructor, might be unnecessary
Private Sub Class_Initialize()

    Set pDict = New Scripting.Dictionary
    
End Sub
Private Sub Class_Terminate()

    Set pDict = Nothing
    
End Sub
Private Function SetList() As List

    Set SetList = List.Copy(pDict.Keys)

End Function
'
' Public Methods
' --------------
'
''
' Enumerator: How we all would love to create our own...
Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4

    Static keyList As List
    Set keyList = SetList
    Set NewEnum = keyList.NewEnum

End Property
'
' Constructors
' ------------
'
Public Function Create(ParamArray args() As Variant) As HashSet
    
    Set Create = Copy(args)
    
End Function
Public Function Copy(ByVal sequence) As HashSet
    
    Dim result As New HashSet
    result.Extend sequence
    Set Copy = result
    
End Function
'
' ### Functional Constructors
'
Public Function Map(ByVal op As Applicable) As HashSet
    
    Set Map = defMap.TransversableMap(HashSet, op, pDict.Keys)
    
End Function
Public Function FlatMap(ByVal op As Applicable) As HashSet
    
    Set FlatMap = defMap.TransversableBind(HashSet, op, pDict.Keys)
    
End Function
Public Function Filter(ByVal pred As Applicable) As HashSet
    
    Set Filter = defFilter.Filter(HashSet, pred, pDict)
    
End Function
Public Function FilterNot(ByVal pred As Applicable) As HashSet
    
    Set FilterNot = defFilter.FilterNot(HashSet, pred, pDict)
    
End Function
'
' Mutability
' ----------
'
' #### Extension
''
' Add: Instead of Insert, Emplace, or Append
Public Sub Add(ByVal element)
    
    If Not Contains(element) Then
        pDict.Add element, Nothing
    End If
    
End Sub
''
' Extend: routed through our `Add`
Public Sub Extend(ByVal sequence)
    
    Dim element
    For Each element In sequence
        Add element
    Next
    
End Sub
'
' #### Removal
'
''
' Removal is by element not by index
Public Sub Remove(ByVal element)
    
    If Contains(element) Then
        pDict.Remove element
    Else
    
        Dim msg As String
        msg = defShow.Show(element) & ", does not exist."
        IndexError Me, "Remove", msg
        
    End If
    
End Sub
Public Sub Discard(ByVal element)

    pDict.Remove element
    
End Sub
Public Sub Clear()

    pDict.Clear
    
End Sub
'
' Interfaces
' ----------
'
'
' ### Buildable
'
Private Function Buildable_MakeEmpty() As Buildable

    Set Buildable_MakeEmpty = Create()

End Function
Private Sub Buildable_AddItem(ByVal element)

    Add element

End Sub
Private Sub Buildable_AddItems(ByVal sequence)

    Extend sequence
    
End Sub
'
' ### SetLike
'
Public Function Contains(ByVal sought) As Boolean
Attribute Contains.VB_UserMemId = 0
    Contains = pDict.Exists(sought)
    
End Function
Public Function Count() As Long

    Count = pDict.Count

End Function
Public Function IsDisJoint(ByVal other As SetLike) As Boolean

    IsDisJoint = defSetLike.IsDisJoint(Me, other)
    
End Function
Public Function IsSubSetOf(ByVal other As SetLike) As Boolean
    
    IsSubSetOf = defSetLike.IsSubSetOf(Me, other)
    
End Function
Public Function IsProperSubSetOf(ByVal other As SetLike) As Boolean

    IsProperSubSetOf = defSetLike.IsProperSubSetOf(Me, other)
    
End Function
Public Function IsSuperSetOf(ByVal other As SetLike) As Boolean

    IsSuperSetOf = defSetLike.IsSuperSetOf(Me, other)
    
End Function
Public Function IsProperSuperSetOf(ByVal other As SetLike) As Boolean

    IsProperSuperSetOf = defSetLike.IsProperSuperSetOf(Me, other)
    
End Function
Public Function Union(ByVal other As SetLike) As HashSet

    Set Union = defSetLike.Union(HashSet, Me, other)
    
End Function
Public Function Intersect(ByVal other As SetLike) As HashSet

    Set Intersect = defSetLike.Intersect(HashSet, Me, other)

End Function
Public Function Difference(ByVal other As SetLike) As HashSet
    
    Set Difference = defSetLike.Difference(HashSet, Me, other)
    
End Function
Public Function SymmetricDifference(ByVal other As SetLike) As HashSet

    Set SymmetricDifference = defSetLike.SymmetricDifference(HashSet, Me, other)
    
End Function
Private Property Get SetLike_Elements() As IUnknown
    
    Set SetLike_Elements = Me.NewEnum
    
End Property
Private Function SetLike_Contains(ByVal sought) As Boolean

    SetLike_Contains = Contains(sought)

End Function
Private Function SetLike_Count() As Long

    SetLike_Count = Count

End Function
Private Function SetLike_IsDisJoint(ByVal other As SetLike) As Boolean

    SetLike_IsDisJoint = IsDisJoint(other)

End Function
Private Function SetLike_IsSubSetOf(ByVal other As SetLike) As Boolean

    SetLike_IsSubSetOf = IsSubSetOf(other)

End Function
Private Function SetLike_IsProperSubSetOf(ByVal other As SetLike) As Boolean

    SetLike_IsProperSubSetOf = IsProperSubSetOf(other)

End Function
Private Function SetLike_IsSuperSetOf(ByVal other As SetLike) As Boolean

    SetLike_IsSuperSetOf = IsSuperSetOf(other)

End Function
Private Function SetLike_IsProperSuperSetOf(ByVal other As SetLike) As Boolean

    SetLike_IsProperSuperSetOf = IsProperSuperSetOf(other)

End Function
Private Function SetLike_Union(ByVal other As SetLike) As SetLike
    
    Set SetLike_Union = Union(other)

End Function
Private Function SetLike_Intersect(ByVal other As SetLike) As SetLike

    Set SetLike_Intersect = Intersect(other)

End Function
Private Function SetLike_Difference(ByVal other As SetLike) As SetLike

    Set SetLike_Difference = Difference(other)

End Function
Private Function SetLike_SymmetricDifference(ByVal other As SetLike) As SetLike

    Set SetLike_SymmetricDifference = SymmetricDifference(other)

End Function
'
' ### Equatable
'
Public Function Equals(ByVal other) As Boolean

    Equals = defSetLike.SetEquals(Me, other)
    
End Function
Private Function Equatable_Equals(ByVal other) As Boolean

    Equatable_Equals = Equals(other)
    
End Function
'
' ### Showable
'
Public Function Show() As String

    Show = defShow.ShowableObject(Me, cast.CArray(pDict.Keys))
    
End Function
Private Function Showable_Show() As String

    Showable_Show = Show
    
End Function
