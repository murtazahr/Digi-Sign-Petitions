contract;

mod data_structures;
mod errors;
mod events;
mod interface;
mod utils;

use ::data_structures::{
    campaign::Campaign,
    campaign_info::CampaignInfo,
    campaign_state::CampaignState,
    signs::Signs,
};
use ::errors::{CampaignError, CreationError, UserError};
use ::events::{
    CancelledCampaignEvent,
    SuccessfulCampaignEvent,
    CreatedCampaignEvent,
    SignedEvent,
    UnsignedEvent,
};
use ::interface::{Petition, Info};
use ::utils::validate_campaign_id;
use std::{
    auth::msg_sender,
    block::height,
    context::msg_amount,
    hash::Hash,
}

storage {
    user_campaign_count: StorageMap<Identity, u64> = StorageMap {},
    campaign_history: StorageMap<(Identity, u64), Campaign> = StorageMap {},
    campaign_info: StorageMap<u64, CampaignInfo> = StorageMap {},
    sign_count: StorageMap<Identity, u64> = StorageMap {},
    sign_history: StorageMap<(Identity, u64), Signs> = StorageMap {},
    sign_history_index: StorageMap<(Identity, u64), u64> = StorageMap {},
    total_campaigns: u64 = 0,
}

impl Petition for Contract {

    #[storage(read, write)]
    fn create_campaign(deadline: u64) {
        require(deadline > height().as_u64(), CreationError::DeadlineMustBeInTheFuture);

        let author = msg_sender().unwrap();

        let campaign_info = Campaign::new(author, deadline);

        let user_campaign_count = storage.user_campaign_count.get(author).try_read().unwrap_or(0);

        storage.total_campaigns.write(storage.total_campaigns.read() + 1);
        storage.campaign_info.insert(storage.total_campaigns.read(), campaign_info);
        storage.user_campaign_count.insert(author, user_campaign_count + 1);
        storage.campaign_history.insert((author, user_campaign_count + 1), Campaign::new(storage.total_campaigns.read()));

        log(CreatedCampaignEvent {
            author, 
            campaign_info,
            campaign_id: storage.total_campaigns.read(),
        });
    }

    #[storage(read, write)]
    fn cancel_campaign(campaign_id: u64) {
        validate_campaign_id(campaign_id, storage.total_campaigns.read());

        let mut campaign_info = storage.campaign_info.get(campaign_id).try_read().unwrap();

        require(campaign_info.author == msg_sender().unwrap(), UserError::UnauthorizedUser);

        require(campaign_info.deadline > height().as_u64(), CampaignError::CampaignEnded);

        require(campaign_info.state != CampaignState::Cancelled, CampaignError::CampaignHasBeenCancelled);

        campaign_info.state = CampaignState::Cancelled;

        storage.campaign_info.insert(campaign_id, campaign_info);

        log(CancelledCampaignEvent { campaign_id });
    }

    #[storage(read, write)]
    fn end_campaign(campaign_id: u64) {
        validate_campaign_id(campaign_id, storage.total_campaigns.read());

        let mut campaign_info = storage.campaign_info.get(campaign_id).try_read().unwrap();

        let mut total_signs = campaign_info.total_signs;

        require(campaign_info.author == msg_sender().unwrap(), UserError::UnauthorizedUser);

        require(campaign_info.state != CampaignState::Successful, UserError::SuccessfulCampaign);

        require(campaign_info.state != CampaignState::Cancelled, CampaignError::CampaignHasBeenCancelled);

        campaign_info.state = CampaignState::Successful;
        storage.campaign_info.insert(campaign_id, campaign_info);

        log(SuccessfulCampaignEvent { campaign_id, total_signs });
    }
}