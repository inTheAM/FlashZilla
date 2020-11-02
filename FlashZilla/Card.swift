//
//  Card.swift
//  FlashZilla
//
//  Created by Ahmed Mgua on 9/24/20.
//

import Foundation

struct Card:	Codable	{
	let prompt:	String
	let answer:	String
	
	static var example:	Card	{
		Card(prompt: "Who played the 13th doctor in Doctor Who?", answer: "Jodie Whittaker")
	}
}
