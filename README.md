
Xcode version: 10.2.1 (10E1001)

# Exam PG5600

## Comments and assumptions

- Made sure to create several folders to improve the structure of the files.
- I created custom cells for each list that was needed.
- All structs were created in the same file.
- When searching for an album data is fetched each time a new letter is entered.
- There is a cancel button next to the searchbar so the user on mobile can remove the keyboard and take use of the navbar again.
- Code structure could have been better, but I made sure to take use of extensions to make it more readable.
- The fetching of data should have been done in a single seperate swift-file instead of doing a fetch request in several files.
- For some reason there are a few instances where the aspect ratio of the image in the detail view doesn't seem to work properly on IPhone XR.
- There is some form of redundancy in the code that could have been handled better.
- I assumed that the order of the favorites did not have to be stored in core data, therfor each time you go back to favorites the old order will be shown again if you have reordered them. 
- If you delete a favorite, that on the other hand will be permanently deleted.

There are improvments to the project as mentioned in the comments above, but the prosject does still meet the requirements of all the tasks given from 1 to 6.

## Cocoapods

Alamofire (Used to fetch the data needed)
- Less code is required for it to work.
- A generic completion callback makes it easier to decode the response that you recieve and send it into custom board types. 
- The URL encoder makes sure to encode parameters by default.
- The response result enum will return the proper result whether it is success or failure.
- The code is easier to read for those who have not written the code.

It is not recommended to use Alamofire if you are looking to build your own networking layer. As it is easier to customize the network requests to your own needs without it.
    
AlamofireImage (Used to set the image in UIImageView)
- Asynchronously downloads an image from the specified URL.
- If the image has been cached locally it will make sure to set the image immediately. 

I set up and if-statement to make sure a placeholder image was set if the URL was empty.
This pod worked perfect for the search page as it would load the pictures quickly as I was fetching the data when typing in the input.

SwiftyJSON
- Less code is required for it to work.
- Easier to read than the typical JSON handling in Swift.
- Serves the same functionality as the typical JSON handling in Swift.
- Workes well with Alamofire.
    
This made the fetching of data in this project much cleaner and easier to read. 


Do keep in mind that these pods are external dependancies to your project. This means that if they are not maintained or tested a lot, they can cause a possible risk to your project. On the other hand the framework seems to be both well maintained and tested, and worked elegant for this project. 
