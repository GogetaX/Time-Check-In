extends Node

"""
Facebook  ads Plugin
https://github.com/MrZak-dev/GodotFAN
"""
#Facebook Ads
@onready var Facebook = null 

"""
replace with your ids
"""
var facebookIds = {
	"facebookInterstitial" : "1444630413076180_1444638239742064",
	"facebookRewarded" : "1444630413076180_1444638316408723",
	"facebookBanner" : "1444630413076180_1444638063075415"
}

var is_facebook_interstitial_ready : bool = false
var is_facebook_rewarded_ready : bool = false
var is_rewarded_completed : bool = false


"""
Facebook  ads 
"""
func _init_facebook() -> void:
	if Engine.has_singleton("GodotFAN"):
		Facebook = Engine.get_singleton("GodotFAN")
		Facebook.FacebookAdsInit(get_instance_id(),facebookIds.facebookInterstitial , facebookIds.facebookRewarded , facebookIds.facebookBanner)
		loadFacebookRewarded()
		loadFacebookBanner()

func loadFacebookRewarded() -> void:
	Facebook.loadRewardedVideo()

##Facebook Ads callbacks
func onRewardedReady() -> void:
	is_facebook_rewarded_ready = true

func onInterstitialReady() -> void:
	is_facebook_interstitial_ready = true

func onInterstitialClosed() -> void:
	is_facebook_interstitial_ready = false

func onRewardedClosed() -> void:
	loadFacebookRewarded()
	if is_rewarded_completed:
		is_rewarded_completed = false
		print("Give Reward")

func onRewardedCompleted() -> void:
	is_rewarded_completed = true

func showFacebookRewraded() -> void:
	if is_facebook_rewarded_ready:
		is_facebook_rewarded_ready = false
		Facebook.showRewardedVideo()

func showFacebookInterstitial() ->void:
	if is_facebook_interstitial_ready:
		Facebook.showInterstitial()

func loadFacebookBanner():
	var isTop = false
	Facebook.loadBanner(isTop)

func LoadFacebookBannerAtBottom():
	Facebook.loadBanner(false)
	
func showFacebookBanner():
	if Facebook != null:
		Facebook.showBanner()

func hideFacebookBanner():
	if Facebook != null:
		Facebook.hideBanner()

