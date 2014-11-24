//
//  RootViewController.swift
//  PagingAnimation
//
//  Created by Andy Steinmann on 11/21/14.


import UIKit

class RootViewController: UIViewController {
	@IBOutlet var scrollView : UIScrollView!
	@IBOutlet var pageControl : UIPageControl?
	
	var _pagingController: PagingController? = nil
	var pagingController: PagingController {
		if _pagingController == nil {
			_pagingController = PagingController(numberOfPages: 5, inContainerVC: self, pagesStoryBoard: self.storyboard!, scrollView:self.scrollView)
			
			//Set the pageControl property if you are using one
			_pagingController?.pageControl = self.pageControl
		}
		return _pagingController!
	}
	

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.pageControl?.numberOfPages = self.pagingController.viewControllers.count
		self.pageControl?.currentPage = 0
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		//IMPORTANT: viewDidLayoutSubviews must be called in order for all the views to get layed out corectly
		self.pagingController.viewDidLayoutSubviews()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}	
	
	@IBAction func pageControl_ValueChanged(sender:AnyObject?)
	{
		self.pagingController.gotoIndex(self.pageControl?.currentPage ?? 0, animated: true)
	}

	
	
}

