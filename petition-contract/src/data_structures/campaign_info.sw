library;

use ::data_structures::campaign_state::CampaignState;

pub struct CampaignInfo {
    author: Identity,
    state: CampaignState,
    deadline: u64,
    total_signs: u64,
}

pub enum Identity {
    Address: Address,
    ContractId: ContractId,
}

impl CampaignInfo {
    // Creates a new campaign
    pub fn new(
        author: Identity,
        deadline: u64,
    ) -> Self {
        Self {
            author,
            state: CampaignState::Progress,
            deadline,
            total_signs: 0,
        }
    }
}