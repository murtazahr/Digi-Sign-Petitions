library;

pub enum CampaignError {
    CampaignEnded: (),
    CampaignHasBeenCancelled: (),
    DeadlineNotReached: (),
}

pub enum CreationError {
    DeadlineMustBeInTheFuture: (),
}

pub enum UserError {
    SuccessfulCampaign: (),
    AlreadySigned: (),
    InvalidID: (),
    UnauthorizedUser: (),
    UserHasNotSigned: (),
}