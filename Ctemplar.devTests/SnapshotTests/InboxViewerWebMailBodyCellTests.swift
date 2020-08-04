import Foundation
import SnapshotTesting
import XCTest
import WebKit
@testable import InboxViewer

class InboxViewerWebMailBodyCellTests: XCTestCase {
    private var content: TextMail {
        return TextMail(messageId: 12345,
                        content: """
                         <!doctype html>
                         <html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
                           <head>
                             <title>
                             </title>
                             <meta http-equiv="X-UA-Compatible" content="IE=edge">
                             <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                             <meta name="viewport" content="width=device-width, initial-scale=1">
                             <style type="text/css">
                               #outlook a{padding: 0;}
                                         .ReadMsgBody{width: 100%;}
                                         .ExternalClass{width: 100%;}
                                         .ExternalClass *{line-height: 100%;}
                                         body{margin: 0; padding: 0; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%;}
                                         table, td{border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt;}
                                         img{border: 0; height: auto; line-height: 100%; outline: none; text-decoration: none; -ms-interpolation-mode: bicubic;}
                                         p{display: block; margin: 13px 0;}
                             </style>
                             <!--[if !mso]><!-->
                             <style type="text/css">
                               @media only screen and (max-width:480px) {
                                                 @-ms-viewport {width: 320px;}
                                                 @viewport {    width: 320px; }
                                             }
                             </style>
                             <!--<![endif]-->
                             <!--[if mso]>
                                 <xml>
                                     <o:OfficeDocumentSettings>
                                         <o:AllowPNG/>
                                         <o:PixelsPerInch>96</o:PixelsPerInch>
                                     </o:OfficeDocumentSettings>
                                 </xml>
                                 <![endif]-->
                             <!--[if lte mso 11]>
                                 <style type="text/css">
                                     .outlook-group-fix{width:100% !important;}
                                 </style>
                                 <![endif]-->
                             <style type="text/css">
                               @media only screen and (max-width:480px) {
                               
                                           table.full-width-mobile { width: 100% !important; }
                                             td.full-width-mobile { width: auto !important; }
                               
                               }
                               @media only screen and (min-width:480px) {
                               .dys-column-per-100 {
                                 width: 100.000000% !important;
                                 max-width: 100.000000%;
                               }
                               }
                               @media only screen and (min-width:480px) {
                               .dys-column-per-100 {
                                 width: 100.000000% !important;
                                 max-width: 100.000000%;
                               }
                               }
                               @media only screen and (min-width:480px) {
                               .dys-column-per-100 {
                                 width: 100.000000% !important;
                                 max-width: 100.000000%;
                               }
                               }
                             </style>
                           </head>
                           <body>
                             <div>
                               <!--[if mso | IE]>
                         <table align="center" border="0" cellpadding="0" cellspacing="0" style="width:600px;" width="600"><tr><td style="line-height:0px;font-size:0px;mso-line-height-rule:exactly;">
                         <![endif]-->
                               <div style='margin:0px auto;max-width:600px;'>
                                 <table align='center' border='0' cellpadding='0' cellspacing='0' role='presentation' style='width:100%;'>
                                   <tbody>
                                     <tr>
                                       <td style='direction:ltr;font-size:0px;padding:20px 0;text-align:center;vertical-align:top;'>
                                         <!--[if mso | IE]>
                         <table role="presentation" border="0" cellpadding="0" cellspacing="0"><tr><td style="vertical-align:top;width:600px;">
                         <![endif]-->
                                         <div class='dys-column-per-100 outlook-group-fix' style='direction:ltr;display:inline-block;font-size:13px;text-align:left;vertical-align:top;width:100%;'>
                                           <table border='0' cellpadding='0' cellspacing='0' role='presentation' style='vertical-align:top;' width='100%'>
                                             <tr>
                                               <td align='center' style='font-size:0px;padding:10px 25px;word-break:break-word;'>
                                                 <table border='0' cellpadding='0' cellspacing='0' role='presentation' style='border-collapse:collapse;border-spacing:0px;'>
                                                   <tbody>
                                                     <tr>
                                                       <td style='width:333px;'>
                                                         <img alt='Welcome!' height='303' src='https://www.sendwithus.com/assets/img/emailmonks/images/banner.jpg' style='border:0;display:block;font-size:13px;height:303px;outline:none;text-decoration:none;width:100%;' width='333' />
                                                       </td>
                                                     </tr>
                                                   </tbody>
                                                 </table>
                                               </td>
                                             </tr>
                                           </table>
                                         </div>
                                         <!--[if mso | IE]>
                         </td></tr></table>
                         <![endif]-->
                                       </td>
                                     </tr>
                                   </tbody>
                                 </table>
                               </div>
                               <!--[if mso | IE]>
                         </td></tr></table>
                         <![endif]-->
                               <!--[if mso | IE]>
                         <table align="center" border="0" cellpadding="0" cellspacing="0" style="width:600px;" width="600"><tr><td style="line-height:0px;font-size:0px;mso-line-height-rule:exactly;">
                         <![endif]-->
                               <div style='margin:0px auto;max-width:600px;'>
                                 <table align='center' border='0' cellpadding='0' cellspacing='0' role='presentation' style='width:100%;'>
                                   <tbody>
                                     <tr>
                                       <td style='direction:ltr;font-size:0px;padding:20px 0;text-align:center;vertical-align:top;'>
                                         <!--[if mso | IE]>
                         <table role="presentation" border="0" cellpadding="0" cellspacing="0"><tr><td style="vertical-align:top;width:600px;">
                         <![endif]-->
                                         <div class='dys-column-per-100 outlook-group-fix' style='direction:ltr;display:inline-block;font-size:13px;text-align:left;vertical-align:top;width:100%;'>
                                           <table border='0' cellpadding='0' cellspacing='0' role='presentation' style='vertical-align:top;' width='100%'>
                                             <tr>
                                               <td align='center' style='font-size:0px;padding:10px 25px;word-break:break-word;'>
                                                 <div style='color:#feae39;font-family:Open Sans, Arial, sans-serif;font-size:18px;font-weight:bold;line-height:20px;text-align:center;text-transform:uppercase;'>
                                                   let us know
                                                 </div>
                                               </td>
                                             </tr>
                                             <tr>
                                               <td align='center' style='font-size:0px;padding:10px 25px;padding-top:20px;word-break:break-word;'>
                                                 <div style='color:#feae39;font-family:Courier New, Arial, sans-serif;font-size:50px;line-height:50px;text-align:center;text-transform:uppercase;'>
                                                   what you think!
                                                 </div>
                                               </td>
                                             </tr>
                                           </table>
                                         </div>
                                         <!--[if mso | IE]>
                         </td></tr></table>
                         <![endif]-->
                                       </td>
                                     </tr>
                                   </tbody>
                                 </table>
                               </div>
                               <!--[if mso | IE]>
                         </td></tr></table>
                         <![endif]-->
                               <table align='center' border='0' cellpadding='0' cellspacing='0' role='presentation' style='background:#30373b;background-color:#30373b;width:100%;'>
                                 <tbody>
                                   <tr>
                                     <td>
                                       <div style='margin:0px auto;max-width:600px;'>
                                         <table align='center' border='0' cellpadding='0' cellspacing='0' role='presentation' style='width:100%;'>
                                           <tbody>
                                             <tr>
                                               <td style='direction:ltr;font-size:0px;padding:2px;text-align:center;vertical-align:top;'>
                                                 <!--[if mso | IE]>
                         <table role="presentation" border="0" cellpadding="0" cellspacing="0"><tr><td style="vertical-align:top;width:600px;">
                         <![endif]-->
                                                 <div class='dys-column-per-100 outlook-group-fix' style='direction:ltr;display:inline-block;font-size:13px;text-align:left;vertical-align:top;width:100%;'>
                                                   <table border='0' cellpadding='0' cellspacing='0' role='presentation' width='100%'>
                                                     <tbody>
                                                       <tr>
                                                         <td style='padding:10px;vertical-align:top;'>
                                                           <table border='0' cellpadding='0' cellspacing='0' role='presentation' style='' width='100%'>
                                                             <!-- Social Icons -->
                                                             <tr>
                                                               <td align='left' style='font-size:0px;padding:10px 25px;word-break:break-word;'>
                                                                 <table border='0' cellpadding='0' cellspacing='0' style='cellpadding:0;cellspacing:0;color:#000000;font-family:Helvetica, Arial, sans-serif;font-size:13px;line-height:22px;table-layout:auto;width:100%;' width='100%'>
                                                                   <tr>
                                                                     <td align='center' valign='top'>
                                                                       <table align='center' border='0' cellpadding='0' cellspacing='0'>
                                                                         <tr>
                                                                           <td valign='top'>
                                                                             <a href='# Facebook' style='text-decoration:none;' target='_blank'>
                                                                               <img alt='Facebook' border='0' height='26' src='https://www.sendwithus.com/assets/img/emailmonks/images/fb.png' style='display:block;font-family: Arial, sans-serif; font-size:10px; line-height:18px; color:#feae39; ' width='26' />
                                                                             </a>
                                                                           </td>
                                                                           <td width='7'>
                                                                             &nbsp;
                                                                           </td>
                                                                           <td valign='top'>
                                                                             <a href='# Twitter' style='text-decoration:none;' target='_blank'>
                                                                               <img alt='Twitter' border='0' height='26' src='https://www.sendwithus.com/assets/img/emailmonks/images/tw.png' style='display:block;font-family: Arial, sans-serif; font-size:10px; line-height:18px; color:#feae39; ' width='26' />
                                                                             </a>
                                                                           </td>
                                                                           <td width='7'>
                                                                             &nbsp;
                                                                           </td>
                                                                           <td valign='top'>
                                                                             <a href='# Pinterest' style='text-decoration:none;' target='_blank'>
                                                                               <img alt='Pinterest' border='0' height='26' src='https://www.sendwithus.com/assets/img/emailmonks/images/pint.png' style='display:block;font-family: Arial, sans-serif; font-size:10px; line-height:18px; color:#feae39; ' width='26' />
                                                                             </a>
                                                                           </td>
                                                                           <td width='7'>
                                                                             &nbsp;
                                                                           </td>
                                                                           <td valign='top'>
                                                                             <a href='# Instagram' style='text-decoration:none;' target='_blank'>
                                                                               <img alt='Instagram' border='0' height='26' src='https://www.sendwithus.com/assets/img/emailmonks/images/insta.png' style='display:block;font-family: Arial, sans-serif; font-size:10px; line-height:18px; color:#feae39; ' width='26' />
                                                                             </a>
                                                                           </td>
                                                                           <td width='7'>
                                                                             &nbsp;
                                                                           </td>
                                                                           <td valign='top'>
                                                                             <a href='# Youtube' style='text-decoration:none;' target='_blank'>
                                                                               <img alt='Youtube' border='0' height='26' src='https://www.sendwithus.com/assets/img/emailmonks/images/yt.png' style='display:block;font-family: Arial, sans-serif; font-size:10px; line-height:18px; color:#feae39; ' width='26' />
                                                                             </a>
                                                                           </td>
                                                                         </tr>
                                                                       </table>
                                                                     </td>
                                                                   </tr>
                                                                 </table>
                                                               </td>
                                                             </tr>
                                                             <!-- End Social Icons -->
                                                             <!-- Footer Content -->
                                                             <tr>
                                                               <td align='center' style='font-size:0px;padding:5px;word-break:break-word;'>
                                                                 <div style='color:#848789;font-family:Open Sans, Arial, sans-serif;font-size:12px;line-height:18px;text-align:center;text-transform:uppercase;'>
                                                                   <a href='# Privacy' style='text-decoration:underline; color:#848789;' target='_blank'>
                                                                     PRIVACY STATEMENT
                                                                   </a>
                                                                   &nbsp;&nbsp;|&nbsp;&nbsp;
                                                                   <a href='# TOS' style='text-decoration:underline; color:#848789;' target='_blank'>
                                                                     TERMS OF SERVICE
                                                                   </a>
                                                                   &nbsp;&nbsp;|&nbsp;&nbsp;
                                                                   <a href='# Returns' style='text-decoration:underline; color:#848789;' target='_blank'>
                                                                     RETURNS
                                                                   </a>
                                                                 </div>
                                                               </td>
                                                             </tr>
                                                             <tr>
                                                               <td align='center' style='font-size:0px;padding:5px;word-break:break-word;'>
                                                                 <div style='color:#848789;font-family:Open Sans, Arial, sans-serif;font-size:12px;line-height:18px;text-align:center;text-transform:uppercase;'>
                                                                   ©2‌019 company name. All Rights Reserved.
                                                                 </div>
                                                               </td>
                                                             </tr>
                                                             <tr>
                                                               <td align='center' style='font-size:0px;padding:5px;word-break:break-word;'>
                                                                 <div style='color:#848789;font-family:Open Sans, Arial, sans-serif;font-size:12px;line-height:18px;text-align:center;text-transform:uppercase;'>
                                                                   If you do not wish to receive any further emails from us, please
                                                                   <span style='text-decoration:underline;'>
                                                                     <a href='#' style='text-decoration:underline; color:#848789;' target='_blank'>
                                                                       unsubscribe
                                                                     </a>
                                                                   </span>
                                                                 </div>
                                                               </td>
                                                             </tr>
                                                             <!-- End Footer Content -->
                                                           </table>
                                                         </td>
                                                       </tr>
                                                     </tbody>
                                                   </table>
                                                 </div>
                                                 <!--[if mso | IE]>
                         </td></tr></table>
                         <![endif]-->
                                               </td>
                                             </tr>
                                           </tbody>
                                         </table>
                                       </div>
                                     </td>
                                   </tr>
                                 </tbody>
                               </table>
                             </div>
                           </body>
                         </html>
                        """,
                        state: .expanded
        )
    }
    
    override class func setUp() {
        super.setUp()
        // record = false
    }
    
    func testContentCell() {
        let contentCell = InboxViewerWebMailBodyCell(style: .default, reuseIdentifier: InboxViewerTextMailBodyCell.className)
        contentCell.configure(with: content)
        contentCell.frame.size.height = 200.0
        assertSnapshot(matching: contentCell, as: .image)
    }
}

extension Snapshotting where Value == WKWebView, Format == UIImage {
  public static let image = Snapshotting(
    pathExtension: "png",
    diffing: .image,
    asyncSnapshot: { webView in
      Async { callback in
        webView.takeSnapshot(with: nil) { image, error in
          callback(image!)
        }
      }
    }
  )
}
