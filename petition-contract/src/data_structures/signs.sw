library;

pub struct Signs {
    // Signing to a campaign; it should always be 1
    sign: u8;
    campaign_id: u64;
}

impl Signs {
    pub fn new(campaign_id: u64) -> Self {
        Self {
            sign: 1,
            campaign_id
        }
    }
}