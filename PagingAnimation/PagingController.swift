//
//  PagingController.swift
//  PagingController
//
//  Created by Andy Steinmann on 11/21/14.


import UIKit


public class PagingController: NSObject, UIScrollViewDelegate {

	public var viewControllers = NSMutableArray()
	public var pageControl: UIPageControl?
	
	internal var storyboard :UIStoryboard!
	internal var containerVC : UIViewController!
	internal var scrollView : UIScrollView!
	
	
	//numberOfPages: Total number of pages that are going to be displayed
	//pagesStoryBoard: A reference to the storyboard that contains the ViewControllers labeled Page1, Page2... etc
	//scrollView: A Reference to the scrollView to present the pages in
	init(numberOfPages:Int, inContainerVC:UIViewController, pagesStoryBoard:UIStoryboard, scrollView:UIScrollView) {
		super.init()
		self.containerVC = inContainerVC
		self.storyboard = pagesStoryBoard
		
		//Setup scrollView properties
		self.scrollView = scrollView
		self.scrollView.delegate = self
		self.scrollView.pagingEnabled = true
		self.scrollView.showsHorizontalScrollIndicator = false
		self.scrollView.showsVerticalScrollIndicator = false
		self.scrollView.scrollsToTop = false
		self.scrollView.alwaysBounceVertical = false
		
		//Add placeholders for each page viewcontroller
		for index in 0..<numberOfPages
		{
			viewControllers.addObject(NSNull())
		}
		
		//Load the first page (plus one on each side to prevent flickering when scrolling
		self.loadScrollViewWithIndex(0)
		
		//Update Title for first page
		self.updateTitle(0)
	}

	//Retrieve the viewcontroller at the specific index
	//The caveat with this is that if the object returned is NSNull it will load from the storyboard
	func viewControllerAtIndex(index: Int) -> UIViewController? {
		// Return the data view controller for the given index.
		if (index >= self.viewControllers.count || index < 0) { return nil }
		
		if let vc = self.viewControllers.objectAtIndex(index) as? UIViewController
		{
			if vc.isKindOfClass(UIViewController) { return vc }
		}
		return self.loadPage(index);
	}

	
	//Retrieves view controller from storyboard based on the Identifier
	//e.g. Page1
	func loadPage(index: Int) -> UIViewController?
	{
		if let vc = storyboard.instantiateViewControllerWithIdentifier("Page\(index + 1)") as? UIViewController
		{
			self.viewControllers.replaceObjectAtIndex(index, withObject: vc)
			return vc
		}
		return nil;
	}
	
	//Loads and navigates to a specific page.  This is useful when implementing a UIPageControl
	// or jumping to a specific page via a menu or drawer
	public func gotoIndex(index:Int, animated:Bool)
	{
		self.loadScrollViewWithIndex(index)
		
		let height: CGFloat =  CGRectGetHeight(self.scrollView.bounds)
		let width: CGFloat = CGRectGetWidth(self.scrollView.bounds)
		let x: CGFloat = width * CGFloat(index)
		let y: CGFloat = 0.0
		
		self.scrollView.scrollRectToVisible(CGRectMake(x, y, width, height), animated: animated)
		self.updateTitle(index)
	}
	
	//Reads the title property off of the current page's view controller and sets it on the container view controller
	func updateTitle(index:Int)
	{
		let currentVC = self.viewControllerAtIndex(index)
		self.containerVC.navigationItem.title = currentVC?.title
	}
	
	
	//MARK: - UIViewController Events
	//IMPORTANT: must be called from viewDidLayoutSubviews in the containing view controller in order for views to be updated properly
	//Updates the scrollView content size to reflect the number of pages
	//places the views into the scrollview at the correct positions
	public func viewDidLayoutSubviews()
	{
		var cs:CGSize = self.scrollView.contentSize
		let viewFrame: CGRect = self.containerVC.view.frame
		
		if cs.height == 0 || cs.width == 0
		{
			let width = CGRectGetWidth(viewFrame) * CGFloat(self.viewControllers.count)
			let height = CGRectGetHeight(viewFrame)
			
			var cs = CGSizeMake(width, height)
			self.scrollView.contentSize = cs
		}
		
		for index in 0..<self.viewControllers.count
		{
			if let vc = self.viewControllers.objectAtIndex(index) as? UIViewController
			{
				let height: CGFloat =  CGRectGetHeight(viewFrame)
				let width: CGFloat = CGRectGetWidth(viewFrame)
				let x: CGFloat = width * CGFloat(index)
				let y: CGFloat = 0.0
				
				let frame: CGRect = CGRectMake(x, y, width, height)
				vc.view.frame = frame
			}
		}
	}
	
	

	//MARK: - Scroll View Delegate
	//UIScrollView Deleaget - animate down to 90% of origional size.
	public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		for vc:AnyObject in self.viewControllers
		{
			if vc.isKindOfClass(UIViewController)
			{
				let animation = { () -> Void in
					let view = vc.view!! as UIView
					view.transform = CGAffineTransformMakeScale(0.9, 0.9)
					view.layer.cornerRadius = 10.0
					view.layer.masksToBounds = true
				}
				
				UIView.animateWithDuration(0.4, animations: animation)
			}
		}
	}
	
	//UIScrollView Delegate - animate views back to regular size
	public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		for vc:AnyObject in self.viewControllers
		{
			if vc.isKindOfClass(UIViewController)
			{
				let animation = { () -> Void in
					let view = vc.view!! as UIView
					view.transform = CGAffineTransformMakeScale(1, 1)
					view.layer.cornerRadius = 0
				}
				UIView.animateWithDuration(0.4, animations: animation)
			}
		}
	}
	
	//UIScrollView Delegate when scrolling is done.
	//Figure out current page and load it (should already be loaded but just as a precaution
	//Update the title and the pageControl if it exists
	public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		let pageWidth = CGRectGetWidth(scrollView.frame)
		let index = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth)) + 1;
		self.loadScrollViewWithIndex(index)
		self.updateTitle(index)
		self.pageControl?.currentPage = index
	}
	
	
	//Add the view for the current index, plus one on each side to prevent flickering when scrolling
	func loadScrollViewWithIndex(index:Int)
	{
		for i in index-1...index+1
		{
			if let vc = self.viewControllerAtIndex(i)
			{
				if vc.view!.superview == nil
				{
					self.containerVC!.addChildViewController(vc)
					self.scrollView.addSubview(vc.view)
					vc.didMoveToParentViewController(self.containerVC)
				}
			}
		}
	}
	
	
	
	
	
}

