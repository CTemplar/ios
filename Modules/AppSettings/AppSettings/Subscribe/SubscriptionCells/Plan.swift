//
//  Plan.swift
//  Sub
//


import UIKit

struct Plan : Codable{
    var name : String
    var email_count : Int
    var domain_count : Int
    var storage : Int
    var monthly_price : Int
    var annually_price : Int
    var background : String
    var messages_per_day : Int
    var gb : Int
    var aliases : Int
    var custom_domains : Int
    var encryption_in_transit : Bool
    var encryption_at_rest : Bool
    var encrypted_attachments : Bool
    var encrypted_content : Bool
    var encrypted_contacts : Bool
    var encrypted_subjects : Bool
    var encrypted_body : Bool
    var encrypted_metadata : Bool
    var two_fa : Bool
    var anti_phishing : Bool
    var attachment_upload_limit : Int
    var brute_force_protection : Bool
    var anonymized_ip : Bool
    var remote_encrypted_link : Bool
    var zero_knowledge_password : Bool
    var strip_ips : Bool
    var sri : Bool
    var checksums : Bool
    var multi_user_support : Bool
    var self_destructing_emails : Bool
    var dead_man_timer : Bool
    var delayed_delivery : Bool
    var four_data_deletion_methods : Bool
    var virus_detection_tool : Bool
    var catch_all_email : Bool
    var unlimited_folders : Bool
    var exclusive_access : Bool
}
