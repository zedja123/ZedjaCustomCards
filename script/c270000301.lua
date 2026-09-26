--
--Lavoisier Proust
--scripted by Zedja
local s,id=GetID()
local SET_LAVOISIER=0xe03
local CARD_LAVOISIER_SPHERE_FIELD=270000308
function s.initial_effect(c)
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	--If you control no monsters in your Main Monster Zones: You can Special Summon this card from your Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp) return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MMZONE,0,1,nil) end)
	e1:SetCost(s.lockcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If a "Lavoisier" Link Monster(s) is Special Summoned to your field: You can Special Summon this card from your Pendulum Zone to your zone that Link Monster points to
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.linkspcon)
	e2:SetCost(s.lockcost)
	e2:SetTarget(s.linksptg)
	e2:SetOperation(s.linkspop)
	c:RegisterEffect(e2)
	--If this card is Summoned: You can add 1 "Lavoisier" monster from your Deck to your hand, except "Lavoisier Proust"
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,2))
	e3a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3a:SetProperty(EFFECT_FLAG_DELAY)
	e3a:SetCode(EVENT_SUMMON_SUCCESS)
	e3a:SetCountLimit(1,{id,2})
	e3a:SetTarget(s.thtg)
	e3a:SetOperation(s.thop)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3b)
	local e3c=e3a:Clone()
	e3c:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3c)
	--If a "Lavoisier" Link Monster(s) is Summoned to your field while this card is face-up in your Extra Deck: You can place this card in your Pendulum Zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetCountLimit(1,{id,3})
	e4:SetCondition(s.pzcon)
	e4:SetTarget(s.pztg)
	e4:SetOperation(s.pzop)
	c:RegisterEffect(e4)
	--While a Link Monster points to this card, that Link Monster gains this effect: You can add 1 "Lavoisier Sphere Field" from your Deck to your hand
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,4})
	e5:SetTarget(s.fthtg)
	e5:SetOperation(s.fthop)
	local e5a=Effect.CreateEffect(c)
	e5a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5a:SetRange(LOCATION_MZONE)
	e5a:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5a:SetTarget(s.granttg)
	e5a:SetLabelObject(e5)
	c:RegisterEffect(e5a)
	--Track Special Summons from the Extra Deck of non-"Lavoisier" monsters
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(SET_LAVOISIER) end)
end
s.listed_names={id,CARD_LAVOISIER_SPHERE_FIELD}
s.listed_series={SET_LAVOISIER}
function s.lockcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--You cannot Special Summon from the Extra Deck the turn you activate either of these effects, except "Lavoisier" monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,5))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_LAVOISIER) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--"Clock Lizard" check
	aux.addTempLizardCheck(e:GetHandler(),tp,function(e,c) return not c:IsOriginalSetCard(SET_LAVOISIER) end)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.linkfilter(c,tp)
	return c:IsFaceup() and c:IsLinkMonster() and c:IsSetCard(SET_LAVOISIER) and c:IsControler(tp)
end
function s.linkspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.linkfilter,1,nil,tp)
end
function s.linkzone(eg,tp)
	local zone=0
	for tc in eg:Filter(s.linkfilter,nil,tp):Iter() do
		zone=zone|tc:GetLinkedZone(tp)
	end
	return zone&ZONES_MMZ
end
function s.linksptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=s.linkzone(eg,tp)
	if chk==0 then return zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.linkspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=s.linkzone(eg,tp)
	if c:IsRelateToEffect(e) and zone~=0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_LAVOISIER) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and eg:IsExists(s.linkfilter,1,nil,tp)
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) and not e:GetHandler():IsForbidden() end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.CheckPendulumZones(tp) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.granttg(e,c)
	return c:IsLinkMonster() and c:GetLinkedGroup():IsContains(e:GetHandler())
end
function s.fthfilter(c)
	return c:IsCode(CARD_LAVOISIER_SPHERE_FIELD) and c:IsAbleToHand()
end
function s.fthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fthfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.fthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.fthfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
