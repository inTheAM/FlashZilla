//
//  ContentView.swift
//  FlashZilla
//
//  Created by Ahmed Mgua on 9/22/20.
//

import SwiftUI


struct ContentView: View {
	@Environment(\.accessibilityDifferentiateWithoutColor)	var differentiateWithoutColor
	@Environment(\.accessibilityEnabled)	var	accessibilityEnabled
	@State private var	cards	=	[Card]()
	@State private var timeRemaining	=	10
	@State private var timer	=	Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	@State private	var	showingEditScreen	=	false
	
	
	@State private var isActive	=	true
	
	func removeCard(at	index:	Int)	{
		guard index	>=	0 else {	return	}
		cards.remove(at: index)
		if cards.isEmpty	{
			self.timeRemaining	=	0
			isActive	=	false
			print("GAME OVER")
		}	else	{
			self.timeRemaining	=	10
		}
	}
	
	func resetCards()	{
		timeRemaining	=	10
		isActive	=	true
		loadData()
		self.timer	=	Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	}
	
	func gameOver()	{
		
		self.timeRemaining	=	0
		self.timer.upstream.connect().cancel()
	}
	
	func	loadData()	{
		if let data	=	UserDefaults.standard.data(forKey: "Cards")	{
			if let decoded	=	try?	JSONDecoder().decode([Card].self, from: data)	{
				self.cards	=	decoded
			}
		}
	}
	
	var body: some View	{
//		ZSTACK FOR BACKGROUND AND FOREGROUND
		ZStack {
//			BACKGROUND IMAGE
			Image(decorative: "background")
				.resizable()
				.scaledToFill()
				.edgesIgnoringSafeArea(.all)
			
			ZStack {
//				VSTACK FOR PLUS BUTTON
				VStack {
					HStack	{
						Spacer()
						
						Button(action:	{
							self.showingEditScreen	=	true
						})	{
							Image(systemName: "plus.circle")
								.padding()
								.background(Color.black.opacity(0.7))
								.clipShape(Circle())
						}
					}
					Spacer()
				}
				.foregroundColor(.white)
				.font(.largeTitle)
				.padding()
				
				if differentiateWithoutColor	||	accessibilityEnabled	{
//					VSTACK FOR SPACER AND CORRECT AND INCORRECT BUTTONS
					VStack	{
						Spacer()
//						HSTACK FOR CORRECT AND INCRORRECT BUTTONS
						HStack	{
							Button(action:	{
								withAnimation	{
									self.removeCard(at: self.cards.count	-	1)
								}
							})	{
								Image(systemName: "xmark.circle")
									.padding()
									.background(Color.black.opacity(0.7))
									.clipShape(Circle())
							}
							Spacer()
							
							Button(action:	{
								withAnimation	{
									self.removeCard(at: self.cards.count	-	1)
								}
							})	{
								Image(systemName: "checkmark.circle")
									.padding()
									.background(Color.black.opacity(0.7))
									.clipShape(Circle())
							}
						}
					}
				}
//				VSTACK FOR TIME AND CARDS
				VStack {

					Text("Time: \(timeRemaining)")
						.font(.largeTitle)
						.foregroundColor(.white)
						.padding(.horizontal)
						.padding(.vertical,	5)
						.background(
							Capsule()
								.fill(Color.black)
								.opacity(0.75)
						)
//					CARDS
					ZStack	{
						ForEach(0..<cards.count,	id:	\.self)	{	index in
							CardView(card: self.cards[index])	{
								withAnimation	{
									self.removeCard(at: index)
								}
							}
							.stacked(at: index, in: self.cards.count)
							.allowsHitTesting(index	==	self.cards.count	-	1)
							.accessibility(hidden: index	<	self.cards.count	-	1)
							
						}
					}.allowsHitTesting(timeRemaining	>	0)
//					GAME OVER VIEW
					if	cards.isEmpty	{
						VStack	{
							Text("Game Over")
								.font(.largeTitle)
								.foregroundColor(.black)
							Button("Restart",	action:	resetCards)
								.padding()
								.background(Color.white)
								.foregroundColor(.black)
								.clipShape(Capsule())
						}
					}
				}
			}
			.onReceive(timer)	{	time in
				guard	self.isActive	else	{return}
				if self.timeRemaining	>	0	{
					self.timeRemaining	-=	1
				}	else	if timeRemaining	==	0	{
					withAnimation	{
						self.removeCard(at: 0)
					}
					
					
				}
			}
			.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification))	{ _ in
				self.isActive	=	false
			}
			.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification))	{ _ in
				if !self.cards.isEmpty	{
					self.isActive	=	true
				}
			}
		}
		.sheet(isPresented: $showingEditScreen, onDismiss: resetCards)	{
			EditCardsView()
		}
		.onAppear(perform:	resetCards)
	}
}





extension	View	{
	func stacked(at	position:	Int,	in	total:	Int) -> some	View	{
		let offset	=	CGFloat(total	-	position)
		return	self.offset(CGSize(width: 0, height: offset	*	10))
	}
}





struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
