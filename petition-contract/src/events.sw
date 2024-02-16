library;

use ::data_structures::campaign_info::CampaignInfo;

pub struct CancelledCampaignEvent {
    campaign_id: u64,
}

pub struct SuccessfulCampaignEvent {
    campaign_id: u64,
    total_signs: u64,
}

pub struct CreatedCampaignEvent {
    author: Identity,
    campaign_info: CampaignInfo,
    campaign_id: u64,
}

pub struct SignedEvent {
    user: Identity,
    campaign_id: u64,
}

pub struct UnsignedEvent {
    campaign_id: u64,
    user: Identity,
}