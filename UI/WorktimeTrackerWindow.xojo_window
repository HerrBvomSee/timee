#tag Window
Begin Window WorktimeTrackerWindow
   BackColor       =   &cFFFFFF00
   Backdrop        =   0
   CloseButton     =   True
   Compatibility   =   ""
   Composite       =   False
   Frame           =   0
   FullScreen      =   False
   FullScreenButton=   False
   HasBackColor    =   False
   Height          =   300
   ImplicitInstance=   True
   LiveResize      =   True
   MacProcID       =   0
   MaxHeight       =   32000
   MaximizeButton  =   True
   MaxWidth        =   32000
   MenuBar         =   1377795362
   MenuBarVisible  =   True
   MinHeight       =   300
   MinimizeButton  =   True
   MinWidth        =   380
   Placement       =   0
   Resizeable      =   True
   Title           =   "Worktime tracker"
   Visible         =   True
   Width           =   380
   Begin Listbox timingListbox
      AutoDeactivate  =   True
      AutoHideScrollbars=   True
      Bold            =   False
      Border          =   True
      ColumnCount     =   4
      ColumnsResizable=   True
      ColumnWidths    =   ""
      DataField       =   ""
      DataSource      =   ""
      DefaultRowHeight=   -1
      Enabled         =   True
      EnableDrag      =   False
      EnableDragReorder=   False
      GridLinesHorizontal=   0
      GridLinesVertical=   0
      HasHeading      =   True
      HeadingIndex    =   -1
      Height          =   260
      HelpTag         =   ""
      Hierarchical    =   False
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   ""
      Italic          =   False
      Left            =   20
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      RequiresSelection=   False
      Scope           =   0
      ScrollbarHorizontal=   False
      ScrollBarVertical=   True
      SelectionType   =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0.0
      TextUnit        =   0
      Top             =   20
      Underline       =   False
      UseFocusRing    =   True
      Visible         =   True
      Width           =   340
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
   Begin MainToolbar WTTMainToolbar
      Enabled         =   True
      Height          =   32
      Index           =   -2147483648
      InitialParent   =   ""
      Left            =   0
      LockedInPosition=   False
      Scope           =   0
      TabPanelIndex   =   0
      Top             =   0
      Visible         =   True
      Width           =   100
   End
End
#tag EndWindow

#tag WindowCode
	#tag Event
		Sub Open()
		  trackingActive = False
		  
		  timingListbox.Heading(0) = "Date"
		  timingListbox.Heading(1) = "Start"
		  timingListbox.Heading(2) = "Stop"
		  timingListbox.Heading(3) = "Hours"
		  
		  LoadTracking
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub LoadTracking()
		  ' save json structure to default tracking file
		  Dim fi as FolderItem = new FolderItem("tracking.json", FolderItem.PathTypeNative)
		  Dim tin as TextInputStream
		  
		  dim jin as JSONItem
		  
		  Try
		    tin = TextInputStream.Open(fi)
		  Catch e as IOException
		    return
		  End Try
		  
		  jin = new JSONItem(tin.ReadAll)
		  
		  tin.Close
		  
		  Dim tracks As JSONItem
		  tracks = jin.Child("Tracks")
		  
		  For i as Integer = 0 To tracks.Count - 1
		    timingListbox.AddRow ""
		    timingListbox.Cell(timingListbox.LastIndex, 1) = tracks.Child(i).Value("StartTime").StringValue
		    timingListbox.Cell(timingListbox.LastIndex, 2) = tracks.Child(i).Value("StopTime").StringValue
		  Next i
		  
		  System.DebugLog jin.ToString
		  System.DebugLog tracks.ToString
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SaveTracking()
		  ' convert the content of the timing listbox into json items
		  ' and save these to disk
		  
		  dim itmlist as new JSONItem  ' the root item
		  
		  itmlist.Compact = False
		  itmlist.Value("Name") = "test"
		  ' todo: define global data
		  
		  Dim tracking as new JSONItem  ' the time tracking jsonitem (used as array)
		  
		  ' now iterate through the listbox, convert all lines into items nad append
		  ' these to the tracking item
		  For i as Integer = 0 To timingListbox.LastIndex
		    Dim singleTrack As New JSONItem
		    singleTrack.Value("StartTime") = str(timingListbox.Cell(i, 1))
		    singleTrack.Value("StopTime") = str(timingListbox.Cell(i, 2))
		    tracking.Append(singleTrack)
		  Next i
		  
		  ' add tracking item to root item
		  itmlist.Value("Tracks") = tracking
		  
		  ' save json structure to default tracking file
		  Dim fou as FolderItem = new FolderItem("tracking.json")
		  dim tout as TextOutputStream
		  tout = TextOutputStream.Create(fou)
		  tout.Write itmlist.ToString
		  tout.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub TimeTracking()
		  If trackingActive = False Then
		    trackingBegin = new Date()
		    timingListbox.AddRow trackingBegin.SQLDate
		    timingListbox.Cell(timingListbox.LastIndex, 1) = trackingBegin.LongTime
		  Else
		    trackingEnd = new Date()
		    timingListbox.Cell(timingListbox.LastIndex, 2) = trackingEnd.LongTime
		    Dim dt as Double = trackingEnd.TotalSeconds - trackingBegin.TotalSeconds
		    timingListbox.Cell(timingListbox.LastIndex, 3) = format(dt / 3600, "#.#0")
		    SaveTracking
		  End If
		  
		  trackingActive = Not trackingActive
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private trackingActive As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private trackingBegin As Date
	#tag EndProperty

	#tag Property, Flags = &h21
		Private trackingEnd As Date
	#tag EndProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  Return UnixTimestamp
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  self.UnixTimestamp = value - 2082844800
			End Set
		#tag EndSetter
		Private UnixTimestamp As Integer
	#tag EndComputedProperty


#tag EndWindowCode

#tag Events WTTMainToolbar
	#tag Event
		Sub Action(item As ToolItem)
		  Select Case item.Name
		  Case "StartToolButton"
		    TimeTracking
		    if trackingActive = True Then
		      item.Caption = "Stop"
		      ToolButton(item).Icon = stop_32
		    else
		      item.Caption = "Start"
		      ToolButton(item).Icon = paly_32
		    End If
		  Case "HelpToolButton"
		    AboutDialog.ShowModal
		  End Select
		End Sub
	#tag EndEvent
#tag EndEvents
#tag ViewBehavior
	#tag ViewProperty
		Name="BackColor"
		Visible=true
		Group="Appearance"
		InitialValue="&hFFFFFF"
		Type="Color"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Backdrop"
		Visible=true
		Group="Appearance"
		Type="Picture"
		EditorType="Picture"
	#tag EndViewProperty
	#tag ViewProperty
		Name="CloseButton"
		Visible=true
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Composite"
		Group="Appearance"
		InitialValue="False"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Frame"
		Visible=true
		Group="Appearance"
		InitialValue="0"
		Type="Integer"
		EditorType="Enum"
		#tag EnumValues
			"0 - Document"
			"1 - Movable Modal"
			"2 - Modal Dialog"
			"3 - Floating Window"
			"4 - Plain Box"
			"5 - Shadowed Box"
			"6 - Rounded Window"
			"7 - Global Floating Window"
			"8 - Sheet Window"
			"9 - Metal Window"
			"10 - Drawer Window"
			"11 - Modeless Dialog"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="FullScreen"
		Group="Appearance"
		InitialValue="False"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="FullScreenButton"
		Visible=true
		Group="Appearance"
		InitialValue="False"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasBackColor"
		Visible=true
		Group="Appearance"
		InitialValue="False"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Height"
		Visible=true
		Group="Position"
		InitialValue="400"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="ImplicitInstance"
		Visible=true
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Interfaces"
		Visible=true
		Group="ID"
		Type="String"
		EditorType="String"
	#tag EndViewProperty
	#tag ViewProperty
		Name="LiveResize"
		Visible=true
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MacProcID"
		Group="Appearance"
		InitialValue="0"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaxHeight"
		Visible=true
		Group="Position"
		InitialValue="32000"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximizeButton"
		Visible=true
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaxWidth"
		Visible=true
		Group="Position"
		InitialValue="32000"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBar"
		Visible=true
		Group="Appearance"
		Type="MenuBar"
		EditorType="MenuBar"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBarVisible"
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinHeight"
		Visible=true
		Group="Position"
		InitialValue="64"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimizeButton"
		Visible=true
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinWidth"
		Visible=true
		Group="Position"
		InitialValue="64"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Name"
		Visible=true
		Group="ID"
		Type="String"
		EditorType="String"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Placement"
		Visible=true
		Group="Position"
		InitialValue="0"
		Type="Integer"
		EditorType="Enum"
		#tag EnumValues
			"0 - Default"
			"1 - Parent Window"
			"2 - Main Screen"
			"3 - Parent Window Screen"
			"4 - Stagger"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Resizeable"
		Visible=true
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Super"
		Visible=true
		Group="ID"
		Type="String"
		EditorType="String"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Title"
		Visible=true
		Group="Appearance"
		InitialValue="Untitled"
		Type="String"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Visible"
		Visible=true
		Group="Appearance"
		InitialValue="True"
		Type="Boolean"
		EditorType="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Width"
		Visible=true
		Group="Position"
		InitialValue="600"
		Type="Integer"
	#tag EndViewProperty
#tag EndViewBehavior
