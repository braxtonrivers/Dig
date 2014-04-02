Rem
	====================================================================
	class providing a base app
	====================================================================

	Your app MUST extend from this class so update/render-functions
	can get called accordingly.
	Only ONE APP AT A TIME is possible


	====================================================================
	LICENCE

	Copyright (C) 2002-2014 Ronny Otto, digidea.de

	This software is provided 'as-is', without any express or
	implied warranty. In no event will the authors be held liable
	for any	damages arising from the use of this software.

	Permission is granted to anyone to use this software for any
	purpose, including commercial applications, and to alter it
	and redistribute it freely, subject to the following restrictions:

	1. The origin of this software must not be misrepresented; you
	   must not claim that you wrote the original software. If you use
	   this software in a product, an acknowledgment in the product
	   documentation would be appreciated but is not required.

	2. Altered source versions must be plainly marked as such, and
	   must not be misrepresented as being the original software.

	3. This notice may not be removed or altered from any source
	   distribution.
	====================================================================
EndRem
SuperStrict
Import "base.util.deltatimer.bmx"
Import "base.util.event.bmx"
Import "base.util.input.bmx"


Type TApp
	Field exitApp:int = FALSE
	Field debugLevel:int = 0
	Global _instance:TApp


	Method New()
		'store as instance
		_instance = self
		_instance.Init()
	End Method


	Function GetInstance:TApp()
		if not _instance then new TApp
		return _instance
	End Function


	Method Init:TApp(updatesPerSecond:Int=60, framesPerSecond:Int=30)
		GetDeltaTimer().Init(updatesPerSecond, framesPerSecond)

		'connect functions
		GetDeltaTimer()._funcUpdate = __Update
		GetDeltaTimer()._funcRender = __Render
	End Method


	Method SetTitle:Int(title:String)
		AppTitle = title
	End Method


	Function __Update:int()
		'refresh mouse/keyboard
		MouseManager.ChangeStatus()
		KeyManager.ChangeStatus()

		'every second update do a system update
		if GetDeltaTimer().timesUpdated mod 2 = 0 then EventManager.triggerEvent( TEventSimple.Create("App.onSystemUpdate",null) )
		'emit event to do update
		EventManager.triggerEvent(TEventSimple.Create("App.onUpdate"))



		'Run the real update function - which might got overridden
		GetInstance().Update()
	End Function


	Function __Render:Int()
		'emit event to render
		EventManager.triggerEvent(TEventSimple.Create("App.onDraw"))

		'Run the real render function - which might got overridden
		GetInstance().Render()
	End Function


	'override this in the extension of TApp
	Method Update:Int()
		print "just exiting the app now"
		GetInstance().exitApp = true
	End Method


	'override this in the extension of TApp
	Method Render:Int()
		'
	End Method


	Method ShutDown:Int()
		print "App shutdown completed. Bye."
	End Method


	'override this to load prerequisites
	Method Prepare:Int()
		print "App starting now."
	End Method


	Method Run:Int()
		Prepare()

		'Init EventManager
		'could also be done during update ("if not initDone...")
		EventManager.Init()

		Repeat
			'run the deltatimer's loop
			'which runs the hooked update/render function
			GetDeltaTimer().loop()

			'process events not directly triggered or delayed ones
			EventManager.update()
			'If RandRange(0,20) = 20 Then GCCollect()
		Until AppTerminate() Or exitApp

		ShutDown()
	End Method
End Type

